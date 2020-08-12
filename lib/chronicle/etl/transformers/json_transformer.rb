require 'json'

module Chronicle
  module Etl
    class JsonTransformer < Chronicle::Etl::Transformer
      def transform data
        return JSON.parse(data)
      end
    end
  end
end
