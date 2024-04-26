require 'pathname'

module Chronicle
  module ETL
    module Extractors
      module Helpers
        module InputReader
          # Return an array of input filenames; converts a single string
          # to an array if necessary
          def filenames
            [@config.input].flatten.map
          end

          # Filenames as an array of pathnames
          def pathnames
            filenames.map { |filename| Pathname.new(filename) }
          end

          # Whether we're reading from files
          def read_from_files?
            filenames.any?
          end

          # Whether we're reading input from stdin
          def read_from_stdin?
            !read_from_files? && $stdin.stat.pipe?
          end

          # Read input sources and yield each content
          def read_input
            if read_from_files?
              pathnames.each do |pathname|
                File.open(pathname) do |file|
                  yield file.read, pathname.to_path
                end
              end
            elsif read_from_stdin?
              yield $stdin.read, $stdin
            else
              raise ExtractionError, 'No input files or stdin provided'
            end
          end

          # Read input sources line by line
          def read_input_as_lines(&block)
            if read_from_files?
              lines_from_files(&block)
            elsif read_from_stdin?
              lines_from_stdin(&block)
            else
              raise ExtractionError, 'No input files or stdin provided'
            end
          end

          private

          def lines_from_files(&block)
            pathnames.each do |pathname|
              File.open(pathname) do |file|
                lines_from_io(file, &block)
              end
            end
          end

          def lines_from_stdin(&block)
            lines_from_io($stdin, &block)
          end

          def lines_from_io(io, &block)
            io.each_line(&block)
          end
        end
      end
    end
  end
end
