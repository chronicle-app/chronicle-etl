module Chronicle
  module Etl
    class NullTransformer < Chronicle::Etl::Transformer
      def transform data
        return data
      end
    end

  end
end