module Chronicle
  module ETL
    class NullTransformer < Chronicle::ETL::Transformer
      def transform data
        return data
      end
    end

  end
end