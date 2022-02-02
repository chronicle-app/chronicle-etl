module Chronicle
  module ETL
    class Extraction
      attr_accessor :data, :meta

      def initialize(data: {}, meta: {})
        @data = data
        @meta = meta
      end
    end
  end
end
