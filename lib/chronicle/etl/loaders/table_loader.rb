require 'tty/table'

module Chronicle
  module Etl
    class TableLoader < Chronicle::Etl::Loader
      def initialize(options)
        super(options)
      end

      def load(result)
        @table ||= TTY::Table.new(header: result.keys)
        @table << result
      end

      def finish
        puts @table.render(:ascii)
      end
    end
  end
end
