module Chronicle
  module ETL
    class NullTransformer < Chronicle::ETL::Transformer
      DESCRIPTION = 'no transformations'

      def transform
        Chronicle::ETL::Models::Generic.new(@extraction.data)
      end
    end
  end
end
