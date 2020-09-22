module Chronicle
  module ETL
    class NullTransformer < Chronicle::ETL::Transformer
      def transform
        Chronicle::ETL::Models::Generic.new(@data)
      end
    end
  end
end
