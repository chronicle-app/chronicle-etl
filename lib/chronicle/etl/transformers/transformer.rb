module Chronicle
  module Etl
    module Transformers
      class Transformer
        def initialize(options = {})
          @options = options
        end

        def transform data
          raise NotImplementedError
        end
      end
    end
  end
end

require_relative 'null_transformer'
require_relative 'json_transformer'
