module Chronicle
  module ETL
    class JobDefinition
      SKELETON_DEFINITION = {
        incremental: false,
        log_each_transformation: false,
        extractor: {
          name: nil,
          options: {}
        },
        transformer: {
          name: nil,
          options: {}
        },
        loader: {
          name: nil,
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

      def log_each_transformation?
        @definition[:log_each_transformation]
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

      def load_klass phase, identifier
        Chronicle::ETL::Registry.phase_and_identifier_to_klass(phase, identifier)
      end

      def load_credentials
        Chronicle::ETL::Registry::PHASES.each do |phase|
          credentials_name = @definition[phase][:options][:credentials]
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
