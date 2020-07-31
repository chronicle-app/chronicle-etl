module Chronicle
  module Etl
    module Transformers
      class Null < Chronicle::Etl::Transformers::Transformer
        def transform data
          return data
        end
      end
    end
  end
end