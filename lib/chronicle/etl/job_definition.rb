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
          name: 'stdout',
          options: {}
        }
      }.freeze

      attr_accessor :definition

      def initialize()
        @definition = SKELETON_DEFINITION
      end

      # Add config hash to this definition
      def add_config(config = {})
        @definition = @definition.deep_merge(config)
        load_credentials
        validate
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

      def validate
        return true   # TODO
      end
    end
  end
end
