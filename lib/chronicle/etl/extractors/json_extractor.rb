module Chronicle
  module ETL
    class JsonExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::FilesystemReader

      register_connector do |r|
        r.description = 'input as JSON'
      end

      setting :filename, default: $stdin
      setting :jsonl, default: true

      def extract
        load_input do |input|
          parsed_data = parse_data(input)
          yield Chronicle::ETL::Extraction.new(data: parsed_data) if parsed_data
        end
      end

      def results_count
      end

      private

      def parse_data data
        JSON.parse(data)
      rescue JSON::ParserError => e
      end

      def load_input
        read_from_filesystem(filename: @options[:filename]) do |data|
          yield data
        end
      end
    end
  end
end
