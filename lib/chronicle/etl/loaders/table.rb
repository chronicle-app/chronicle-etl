require 'table_print'

module Chronicle
  module Etl
    module Loaders
      class Table < Chronicle::Etl::Loaders::Loader
        def initialize(options)
          super(options)
          @rows = []
        end

        def load(result)
          @rows << result
        end

        def finish
          tp @rows
        end
      end
    end
  end
end
