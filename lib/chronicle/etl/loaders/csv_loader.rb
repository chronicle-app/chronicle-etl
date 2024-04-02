# frozen_string_literal: true

require 'csv'
require 'chronicle/utils/hash_utils'

module Chronicle
  module ETL
    class CSVLoader < Chronicle::ETL::Loader
      include Chronicle::ETL::Loaders::Helpers::StdoutHelper

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

        # headers = filtered_headers(records)
        headers = gather_headers(records)

        csv_options = {}
        if @config.headers
          csv_options[:write_headers] = @config.header_row
          csv_options[:headers] = headers
        end

        csv_output = CSV.generate(**csv_options) do |csv|
          records.each do |record|
            csv << Chronicle::Utils::HashUtils.flatten_hash(record.to_h)
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

      private

      def gather_headers(records)
        records_flattened = records.map do |record|
          Chronicle::Utils::HashUtils.flatten_hash(record.to_h)
        end
        all_fields = records_flattened.flat_map(&:keys).uniq
      end
    end
  end
end
