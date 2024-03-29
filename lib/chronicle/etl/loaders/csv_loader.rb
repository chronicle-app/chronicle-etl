# frozen_string_literal: true

require 'csv'

module Chronicle
  module ETL
    class CSVLoader < Chronicle::ETL::Loader
      include Chronicle::ETL::Loaders::Helpers::StdoutHelper
      include Chronicle::ETL::Loaders::Helpers::FieldFilteringHelper

      register_connector do |r|
        r.identifier = :csv
        r.description = 'CSV'
      end

      setting :output
      setting :headers, default: true
      setting :header_row, default: true

      def records
        @records ||= []
      end

      def load(record)
        records << record
      end

      def finish
        return unless records.any?

        headers = filtered_headers(records)

        csv_options = {}
        if @config.headers
          csv_options[:write_headers] = @config.header_row
          csv_options[:headers] = headers
        end

        csv_output = CSV.generate(**csv_options) do |csv|
          records.each do |record|
            csv << record
              .to_h_flattened
              .values_at(*headers)
              .map { |value| force_utf8(value) }
          end
        end

        # TODO: just write to io directly
        if output_to_stdout?
          write_to_stdout(csv_output)
        else
          File.write(@config.output, csv_output)
        end
      end
    end
  end
end
