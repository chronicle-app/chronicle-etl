# frozen_string_literal: true

module Chronicle
  module ETL
    module Registry
      # Records details about a connector such as its source provider and a description
      class ConnectorRegistration
        attr_accessor :klass, :identifier, :source, :strategy, :type, :description, :schema

        # Create a new connector registration
        def initialize(klass)
          @klass = klass
        end

        # The ETL phase of this connector
        def phase
          if klass.ancestors.include? Chronicle::ETL::Extractor
            :extractor
          elsif klass.ancestors.include? Chronicle::ETL::Transformer
            :transformer
          elsif klass.ancestors.include? Chronicle::ETL::Loader
            :loader
          end
        end

        def to_s
          "#{phase}-#{identifier}"
        end

        # Whether this connector is built-in to Chronicle
        def built_in?
          @klass.to_s.include? 'Chronicle::ETL'
        end

        def klass_name
          @klass.to_s
        end

        # TODO: allow overriding here. Maybe through self-registration process
        def plugin
          @source
        end

        def descriptive_phrase
          prefix = case phase
                   when :extractor
                     "Extracts from"
                   when :transformer
                     "Transforms"
                   when :loader
                     "Loads to"
                   end

          "#{prefix} #{description}"
        end
      end
    end
  end
end
