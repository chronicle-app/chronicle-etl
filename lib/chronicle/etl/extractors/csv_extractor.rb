require 'csv'

module Chronicle
  module ETL
    class CsvExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::FilesystemReader

      DEFAULT_OPTIONS = {
        headers: true,
        filename: $stdin
      }.freeze

      def initialize(options = {})
        super(DEFAULT_OPTIONS.merge(options))
      end

      def extract
        csv = initialize_csv
        csv.each do |row|
          yield Chronicle::ETL::Extraction.new(data: row.to_h)
        end
      end

      def results_count
        CSV.read(@options[:filename], headers: @options[:headers]).count unless stdin?(@options[:filename])
      end

      private

      def initialize_csv
        headers = @options[:headers].is_a?(String) ? @options[:headers].split(',') : @options[:headers]

        csv_options = {
          headers: headers,
          converters: :all
        }

        open_from_filesystem(filename: @options[:filename]) do |file|
          return CSV.new(file, **csv_options)
        end
      end
    end
  end
end
