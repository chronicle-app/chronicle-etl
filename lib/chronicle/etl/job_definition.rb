# frozen_string_literal: true

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
        transformers: [
          {
            name: 'null',
            options: {}
          }
        ],
        loader: {
          name: 'json',
          options: {}
        }
      }.freeze

      attr_reader :errors
      attr_accessor :definition

      def initialize
        @definition = SKELETON_DEFINITION
      end

      def valid?
        validate
        @errors.empty?
      end

      def validate
        @errors = {}

        extractor_klass
        transformer_klasses
        loader_klass
      rescue Chronicle::ETL::PluginError => e
        @errors[:plugins] ||= []
        @errors[:plugins] << e
      end

      def plugins_missing?
        validate

        return false unless @errors[:plugins]&.any?

        @errors[:plugins]
          .any? { |e| e.instance_of?(Chronicle::ETL::PluginNotInstalledError) }
      end

      def validate!
        raise(Chronicle::ETL::JobDefinitionError.new(self), 'Job definition is invalid') unless valid?

        true
      end

      # Add config hash to this definition
      def add_config(config = {})
        @definition = @definition.deep_merge(config)
        load_credentials
      end

      # For each connector in this job, mix in secrets into the options
      def apply_default_secrets
        # FIXME: handle transformer secrets
        %i[extractor loader].each do |phase|
          # If the option have a `secrets` key, we look up those secrets and
          # mix them in. If not, use the connector's plugin name and look up
          # secrets with the same namespace
          if @definition[phase][:options][:secrets]
            namespace = @definition[phase][:options][:secrets]
          else
            # We don't want to do this lookup for built-in connectors
            next if __send__(:"#{phase}_klass").connector_registration.built_in?

            # infer plugin name from connector name and use it for secrets
            # namesepace
            namespace = @definition[phase][:name].split(':').first
          end

          # Reverse merge secrets into connector's options (we want to preserve
          # options that came from job file or CLI options)
          secrets = Chronicle::ETL::Secrets.read(namespace)
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
        find_connector_klass(:extractor, @definition[:extractor][:name])
      end

      def transformer_klasses
        @definition[:transformers].map do |transformer|
          find_connector_klass(:transformer, transformer[:name])
        end
      end

      def loader_klass
        find_connector_klass(:loader, @definition[:loader][:name])
      end

      def extractor_options
        @definition[:extractor][:options]
      end

      def transformer_options
        @definition[:transformers].map do |transformer|
          transformer[:options]
        end
      end

      def loader_options
        @definition[:loader][:options]
      end

      private

      def find_schema_transformer_klass(source_klass, target)
        Chronicle::ETL::Registry::Connectors.find_converter_for_source(source_klass, target).klass
      end

      def find_connector_klass(phase, identifier)
        Chronicle::ETL::Registry::Connectors.find_by_phase_and_identifier(phase, identifier).klass
      end

      def load_credentials
        %i[extractor loader].each do |phase|
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
