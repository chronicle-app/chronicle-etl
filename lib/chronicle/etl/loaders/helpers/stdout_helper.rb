require 'tempfile'

module Chronicle
  module ETL
    module Loaders
      module Helpers
        module StdoutHelper
          # TODO: let users use "stdout" as an option for the `output` setting
          # Assume we're using stdout if no output is specified
          def output_to_stdout?
            !@config.output
          end

          def create_stdout_temp_file
            file = Tempfile.new('chronicle-stdout')
            file.unlink
            file
          end

          def write_to_stdout_from_temp_file(file)
            file.rewind
            write_to_stdout(file.read)
          end

          def write_to_stdout(output)
            # We .dup because rspec overwrites $stdout (in helper #capture) to
            # capture output.
            stdout = $stdout.dup
            stdout.write(output)
            stdout.flush
          end
        end
      end
    end
  end
end
