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

      def output(message, level)
        return unless level >= @log_level

        if @ui_element
          @ui_element.log(message)
        else
          warn(message)
        end
      end

      def fatal(message)
        output(message, FATAL)
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

      def attach_to_ui(ui_element)
        @ui_element = ui_element
      end

      def detach_from_ui
        @ui_element = nil
      end
    end
  end
end
