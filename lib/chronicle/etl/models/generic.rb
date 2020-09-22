require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      class Generic < Chronicle::ETL::Models::Base
        TYPE = 'generic'

        attr_accessor :properties

        def initialize(properties = {})
          @properties = properties
          super
        end

        # Generic models have arbitrary attributes stored in @properties
        def attributes
          @properties.transform_keys(&:to_sym)
        end
      end
    end
  end
end
