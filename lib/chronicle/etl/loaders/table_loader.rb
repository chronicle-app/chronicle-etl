require 'tty/table'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/hash/reverse_merge'

module Chronicle
  module ETL
    class TableLoader < Chronicle::ETL::Loader
      include Chronicle::ETL::Loaders::Helpers::FieldFilteringHelper

      register_connector do |r|
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

        headers = filtered_headers(records)
        rows = build_rows(records, headers)

        @table = TTY::Table.new(header: (headers if @config.header_row), rows: rows)
        puts @table.render(
          @config.table_renderer.to_sym,
          padding: [0, 2, 0, 0]
        )
      end

      def records
        @records ||= []
      end

      private

      def build_rows(records, headers)
        records.map do |record|
          values = record
            .to_h_flattened
            .values_at(*headers)
            .map { |value| force_utf8(value.to_s) }

          values = values.map{ |value| value.truncate(@config.truncate_values_at) } if @config.truncate_values_at

          values
        end
      end
    end
  end
end
