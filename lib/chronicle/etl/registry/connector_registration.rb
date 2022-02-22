module Chronicle
  module ETL
    module Registry
      # Records details about a connector such as its provider and a description
      class ConnectorRegistration
        # FIXME: refactor custom accessor methods later in file
        attr_accessor :identifier, :provider, :klass, :description

        def initialize(klass)
          @klass = klass
        end

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

        def built_in?
          @klass.to_s.include? 'Chronicle::ETL'
        end

        def klass_name
          @klass.to_s
        end

        def identifier
          @identifier || @klass.to_s.split('::').last.gsub!(/(Extractor$|Loader$|Transformer$)/, '').downcase
        end

        def description
          @description || @klass.to_s.split('::').last
        end

        def provider
          @provider || (built_in? ? 'chronicle' : '')
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
