require 'tty/table'
require 'active_support/core_ext/string/filters'
require 'active_support/core_ext/hash/reverse_merge'

module Chronicle
  module ETL
    class TableLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.description = 'an ASCII table'
      end

      setting :fields_limit, default: nil
      setting :fields_exclude, default: ['lids', 'type']
      setting :fields_include, default: []
      setting :truncate_values_at
      setting :table_renderer, default: :basic

      def load(record)
        @records ||= []
        @records << record.to_h_flattened
      end

      def finish
        return if @records.empty?

        headers = build_headers(@records)
        rows = build_rows(@records, headers)

        @table = TTY::Table.new(header: headers, rows: rows)
        puts @table.render(
          @config.table_renderer.to_sym,
          padding: [0, 2, 0, 0]
        )
      end

      private

      def build_headers(records)
        headers =
          if @config.fields_include.any?
            Set[*@config.fields_include]
          else
            # use all the keys of the flattened record hash
            Set[*records.map(&:keys).flatten.map(&:to_s).uniq]
          end

        headers = headers.delete_if { |header| header.end_with?(*@config.fields_exclude) } if @config.fields_exclude.any?
        headers = headers.first(@config.fields_limit) if @config.fields_limit

        headers.to_a.map(&:to_sym)
      end

      def build_rows(records, headers)
        records.map do |record|
          values = record.values_at(*headers).map{|value| value.to_s }

          if @config.truncate_values_at
            values = values.map{ |value| value.truncate(@config.truncate_values_at) }
          end

          values
        end
      end
    end
  end
end
