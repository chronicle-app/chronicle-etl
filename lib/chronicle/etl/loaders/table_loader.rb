require 'tty/table'

module Chronicle
  module Etl
    class TableLoader < Chronicle::Etl::Loader
      def initialize(options)
        super(options)
      end

      # defer creating table until we get first result and can determine headers
      def first_load(result)
        headers = result.keys
        @table = TTY::Table.new(header: headers)
      end

      def load(result)
        @table << result
      end

      def finish
        puts @table.render(:ascii)
      end
    end
  end
end
