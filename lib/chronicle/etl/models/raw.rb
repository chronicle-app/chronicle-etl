require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      # A record from an extraction with no processing or normalization applied
      class Raw
        TYPE = 'raw'

        attr_accessor :raw_data

        def initialize(raw_data)
          @raw_data = raw_data
        end

        def to_h
          @raw_data.to_h
        end

        def to_h_flattened
          Chronicle::ETL::Utils::HashUtilities.flatten_hash(to_h)
        end
      end
    end
  end
end
