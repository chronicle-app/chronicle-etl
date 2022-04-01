module Chronicle
  module ETL
    module CLI
      # Base class for CLI commands
      class CLIBase < ::Thor
        no_commands do
          # Shorthand for cli_exit(status: :failure)
          def cli_fail(message: nil, exception: nil)
            message += "\nRe-run the command with --verbose to see details." if Chronicle::ETL::Logger.log_level > Chronicle::ETL::Logger::DEBUG
            cli_exit(status: :failure, message: message, exception: exception)
          end

          # Exit from CLI
          #
          # @params status Can be eitiher :success or :failure
          # @params message to print
          # @params exception stacktrace if log_level is set to debug
          def cli_exit(status: :success, message: nil, exception: nil)
            exit_code = status == :success ? 0 : 1
            log_level = status == :success ? :info : :fatal

            message = message.red if status != :success

            Chronicle::ETL::Logger.debug(exception.full_message) if exception
            Chronicle::ETL::Logger.send(log_level, message) if message
            exit(exit_code)
          end
        end
      end
    end
  end
end
