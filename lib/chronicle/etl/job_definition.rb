require 'active_support/core_ext/hash/deep_merge'

module Chronicle
  module ETL
    class JobDefinition
      SKELETON_DEFINITION = {
        incremental: false,
        extractor: {
          name: 'stdin',
          options: {}
        },
        transformer: {
          name: 'null',
          options: {}
        },
        loader: {
          name: 'table',
          options: {}
        }
      }.freeze

      attr_reader :errors
      attr_accessor :definition

      def initialize()
        @definition = SKELETON_DEFINITION
      end

      def valid?
        validate
        @errors.empty?
      end

      def validate
        @errors = {}

        Chronicle::ETL::Registry::PHASES.each do |phase|
          __send__("#{phase}_klass".to_sym)
        rescue Chronicle::ETL::PluginError => e
          @errors[:plugins] ||= []
          @errors[:plugins] << e
        end
      end

      def plugins_missing?
        validate

        return false unless @errors[:plugins]&.any?

        @errors[:plugins]
          .filter { |e| e.instance_of?(Chronicle::ETL::PluginNotInstalledError) }
          .any?
      end

      def validate!
        raise(Chronicle::ETL::JobDefinitionError.new(self), "Job definition is invalid") unless valid?

        true
      end

      # Add config hash to this definition
      def add_config(config = {})
        @definition = @definition.deep_merge(config)
        load_credentials
      end

      # For each connector, if it's a plugin connector, reverse-merge in
      # secrets from config file with same name as plugin name
      def apply_default_secrets
        Chronicle::ETL::Registry::PHASES.each do |phase|
          # We don't want to do this for built-in connectors
          next if __send__("#{phase}_klass".to_sym).connector_registration.built_in?

          plugin_name = @definition[phase][:name].split(":").first
          secrets = Chronicle::ETL::Secrets.read(plugin_name)

          # Reverse merge secrets into connector's options (we want to preserve
          # options that came from job file or CLI options)
          @definition[phase][:options] = secrets.merge(@definition[phase][:options])
        end
      end

      # Is this job continuing from a previous run?
      def incremental?
        @definition[:incremental]
      end

      def dry_run?
        @definition[:dry_run]
      end

      def extractor_klass
        load_klass(:extractor, @definition[:extractor][:name])
      end

      def transformer_klass
        load_klass(:transformer, @definition[:transformer][:name])
      end

      def loader_klass
        load_klass(:loader, @definition[:loader][:name])
      end

      def extractor_options
        @definition[:extractor][:options]
      end

      def transformer_options
        @definition[:transformer][:options]
      end

      def loader_options
        @definition[:loader][:options]
      end

      private

      def load_klass(phase, identifier)
        Chronicle::ETL::Registry.find_by_phase_and_identifier(phase, identifier).klass
      end

      def load_credentials
        Chronicle::ETL::Registry::PHASES.each do |phase|
          credentials_name = @definition[phase].dig(:options, :credentials)
          if credentials_name
            credentials = Chronicle::ETL::Config.load_credentials(credentials_name)
            @definition[phase][:options].deep_merge(credentials)
          end
        end
      end
    end
  end
end
