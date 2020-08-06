module Chronicle
  module Etl
    module Loaders
      class Loader
        def initialize(options = {})
          @options = options
        end

        def start; end

        def first_load result; end

        def load
          raise NotImplementedError
        end

        def finish; end
      end
    end
  end
end

require_relative 'stdout'
require_relative 'csv'
require_relative 'table'