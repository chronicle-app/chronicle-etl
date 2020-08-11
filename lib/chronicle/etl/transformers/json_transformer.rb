require 'json'

module Chronicle
  module Etl
    module Transformers
      class JsonTransformer < Chronicle::Etl::Transformers::Transformer
        def transform data
          return JSON.parse(data)
        end
      end
    end
  end
end