require 'tty/table'

module Chronicle
  module Etl
    class TableLoader < Chronicle::Etl::Loader
      def initialize(options)
        super(options)
      end

      def load(result)
        @table ||= TTY::Table.new(header: result.keys)
        values = result.values.map{|x| x.to_s[0..30]}
        @table << values
      end

      def finish
        puts @table.render(:ascii, padding: [0, 1])
      end
    end
  end
end
