require 'pathname'

module Chronicle
  module ETL
    module Extractors
      module Helpers
        module FilesystemReader

          def open_files_in_directory(...)
            filenames = gather_files(...)
            filenames.each do |filename|
              file = File.open(filename)
              yield file
            end
          end

          def read_from_filesystem(filename:, yield_each_line: true, dir_glob_pattern: '**/*')
            open_files(filename: filename, dir_glob_pattern: dir_glob_pattern) do |file|
              if yield_each_line
                file.each_line do |line|
                  yield line
                end
              else
                yield file.read
              end
            end
          end

          def open_from_filesystem(filename:, dir_glob_pattern: '**/*')
            open_files(filename: filename, dir_glob_pattern: dir_glob_pattern) do |file|
              yield file
            end
          end

          def results_count
            raise NotImplementedError
            # if file?
            #   return 1
            # else
            #   search_pattern = File.join(@options[:filename], '**/*')
            #   Dir.glob(search_pattern).count
            # end
          end

          private

          def gather_files(path:, dir_glob_pattern: '**/*', load_since: nil, load_until: nil, smaller_than: nil, larger_than: nil, sort: :mtime)
            search_pattern = File.join(path, '**', dir_glob_pattern)
            files = Dir.glob(search_pattern)

            files = files.keep_if {|f| (File.mtime(f) > load_since)} if load_since
            files = files.keep_if {|f| (File.mtime(f) < load_until)} if load_until

            # pass in file sizes in bytes
            files = files.keep_if {|f| (File.size(f) < smaller_than)} if smaller_than
            files = files.keep_if {|f| (File.size(f) > larger_than)} if larger_than

            # TODO: incorporate sort argument
            files.sort_by{ |f| File.mtime(f) }
          end

          def select_files_in_directory(path:, dir_glob_pattern: '**/*')
            raise IOError.new("#{path} is not a directory.") unless directory?(path)

            search_pattern = File.join(path, dir_glob_pattern)
            Dir.glob(search_pattern).each do |filename|
              yield(filename)
            end
          end

          def open_files(filename:, dir_glob_pattern:)
            if stdin?(filename)
              yield $stdin
            elsif directory?(filename)
              search_pattern = File.join(filename, dir_glob_pattern)
              filenames = Dir.glob(search_pattern)
              filenames.each do |filename|
                file = File.open(filename)
                yield(file)
              end
            elsif file?(filename)
              yield File.open(filename)
            end
          end

          def stdin?(filename)
            filename == $stdin
          end

          def directory?(filename)
            Pathname.new(filename).directory?
          end

          def file?(filename)
            Pathname.new(filename).file?
          end
        end
      end
    end
  end
end
