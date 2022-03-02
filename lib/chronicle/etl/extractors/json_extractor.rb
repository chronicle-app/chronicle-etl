module Chronicle
  module ETL
    class JSONExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::InputReader

      register_connector do |r|
        r.description = 'JSON'
      end

      setting :jsonl, default: true, type: :boolean

      def prepare
        @jsons = []
        load_input do |input|
          @jsons << parse_data(input)
        end
      end

      def extract
        @jsons.each do |json|
          yield Chronicle::ETL::Extraction.new(data: json)
        end
      end

      def results_count
        @jsons.count
      end

      private

      def parse_data data
        JSON.parse(data)
      rescue JSON::ParserError
        raise Chronicle::ETL::ExtractionError, "Could not parse JSON"
      end

      def load_input(&block)
        if @config.jsonl
          read_input_as_lines(&block)
        else
          read_input(&block)
        end
      end
    end
  end
end
