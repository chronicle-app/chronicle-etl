module Chronicle
  module ETL
    module Logger
      extend self

      DEBUG = 0
      INFO = 1
      WARN = 2
      ERROR = 3
      FATAL = 4
      SILENT = 5

      attr_accessor :log_level

      @log_level = INFO
      @destination = $stderr

      def output message, level
        return unless level >= @log_level

        if @progress_bar
          @progress_bar.log(message)
        else
          @destination.puts(message)
        end
      end

      def error(message)
        output(message, ERROR)
      end

      def info(message)
        output(message, INFO)
      end

      def debug(message)
        output(message, DEBUG)
      end

      def attach_to_progress_bar(progress_bar)
        @progress_bar = progress_bar
      end

      def detach_from_progress_bar
        @progress_bar = nil
      end
    end
  end
end
