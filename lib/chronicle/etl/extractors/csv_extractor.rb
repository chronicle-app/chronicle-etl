require 'csv'

module Chronicle
  module ETL
    class CSVExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::FilesystemReader

      register_connector do |r|
        r.description = 'input as CSV'
      end

      setting :headers, default: true
      setting :filename, default: $stdin

      def extract
        csv = initialize_csv
        csv.each do |row|
          yield Chronicle::ETL::Extraction.new(data: row.to_h)
        end
      end

      def results_count
        CSV.read(@config.filename, headers: @config.headers).count unless stdin?(@config.filename)
      end

      private

      def initialize_csv
        headers = @config.headers.is_a?(String) ? @config.headers.split(',') : @config.headers

        csv_options = {
          headers: headers,
          converters: :all
        }

        open_from_filesystem(filename: @config.filename) do |file|
          return CSV.new(file, **csv_options)
        end
      end
    end
  end
end
