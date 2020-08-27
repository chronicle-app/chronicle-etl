require 'json'

module Chronicle
  module ETL
    class JsonTransformer < Chronicle::ETL::Transformer
      def transform data
        return JSON.parse(data)
      end
    end
  end
end
