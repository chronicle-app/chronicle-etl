module Chronicle
  module Etl
    module Transformers
      class NullTransformer < Chronicle::Etl::Transformers::Transformer
        def transform data
          return data
        end
      end
    end
  end
end