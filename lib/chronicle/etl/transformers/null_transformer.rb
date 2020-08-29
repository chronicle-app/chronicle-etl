module Chronicle
  module ETL
    class NullTransformer < Chronicle::ETL::Transformer
      def transform
        return @data
      end
    end

  end
end