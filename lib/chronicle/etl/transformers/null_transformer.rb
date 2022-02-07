module Chronicle
  module ETL
    class NullTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = 'null'
        r.description = 'in no way'
      end

      def transform
        Chronicle::ETL::Models::Generic.new(@extraction.data)
      end

      def timestamp; end

      def id; end
    end
  end
end
