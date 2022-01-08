require 'tty/table'

module Chronicle
  module ETL
    class TableLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.description = 'an ASCII table'
      end

      def initialize(options)
        super(options)
      end

      def load(record)
        record_hash = record.to_h_flattened
        @table ||= TTY::Table.new(header: record_hash.keys)
        values = record_hash.values.map{|x| x.to_s[0..30]}
        @table << values
      end

      def finish
        puts @table.render(:ascii, padding: [0, 1]) if @table
      end
    end
  end
end
