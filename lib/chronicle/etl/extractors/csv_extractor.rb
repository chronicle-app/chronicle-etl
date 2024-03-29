# frozen_string_literal: true

require 'csv'

module Chronicle
  module ETL
    class CSVExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::InputReader

      register_connector do |r|
        r.identifier = :csv
        r.description = 'CSV'
      end

      setting :headers, default: true

      def prepare
        @csvs = prepare_sources
      end

      def extract
        @csvs.each do |csv|
          csv.read.each do |row|
            yield Chronicle::ETL::Extraction.new(data: row.to_h)
          end
        end
      end

      def results_count
        @csvs.reduce(0) do |total_rows, csv|
          row_count = csv.readlines.size
          csv.rewind
          total_rows + row_count
        end
      end

      private

      def all_rows
        @csvs.reduce([]) do |all_rows, csv|
          all_rows + csv.to_a.map(&:to_h)
        end
      end

      def prepare_sources
        @csvs = []
        read_input do |csv_data|
          csv_options = {
            headers: @config.headers.is_a?(String) ? @config.headers.split(',') : @config.headers,
            converters: :all
          }
          @csvs << CSV.new(csv_data, **csv_options)
        end
        @csvs
      end
    end
  end
end
