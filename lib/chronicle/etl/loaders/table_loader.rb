# frozen_string_literal: true

require 'tty/table'
require 'chronicle/utils/hash_utils'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/hash/reverse_merge'

module Chronicle
  module ETL
    class TableLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.identifier = :table
        r.description = 'an ASCII table'
      end

      setting :truncate_values_at, default: 40
      setting :table_renderer, default: :basic
      setting :fields_exclude, default: ['type']
      setting :header_row, default: true

      def load(record)
        records << record
      end

      def finish
        return if records.empty?

        headers = gather_headers(records)
        rows = build_rows(records, headers)

        render_table(headers, rows)
      end

      def records
        @records ||= []
      end

      private

      def render_table(headers, rows)
        @table = TTY::Table.new(header: (headers if @config.header_row), rows: rows)
        puts @table.render(
          @config.table_renderer.to_sym,
          padding: [0, 2, 0, 0]
        )
      rescue TTY::Table::ResizeError
        # The library throws this error before trying to render the table
        # vertically. These options seem to work.
        puts @table.render(
          @config.table_renderer.to_sym,
          padding: [0, 2, 0, 0],
          width: 10_000,
          resize: false
        )
      end

      def gather_headers(records)
        records_flattened = records.map do |record|
          Chronicle::Utils::HashUtils.flatten_hash(record.to_h)
        end
        records_flattened.flat_map(&:keys).uniq
      end

      def build_rows(records, headers)
        records.map do |record|
          values = Chronicle::Utils::HashUtils.flatten_hash(record.to_h)
            .values_at(*headers)
            .map { |value| force_utf8(value.to_s) }

          values = values.map { |value| value.truncate(@config.truncate_values_at) } if @config.truncate_values_at

          values
        end
      end
    end
  end
end
