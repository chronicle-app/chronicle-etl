require 'deep_merge'

module Chronicle
  module ETL
    class JobDefinition
      SKELETON_DEFINITION = {
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
        @definition = config.deep_merge(@definition)
        load_credentials
        validate
      end

      private

      def load_credentials
        Chronicle::ETL::Catalog::PHASES.each do |phase|
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
