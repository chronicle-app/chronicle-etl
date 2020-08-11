module Chronicle
  module Etl
    module Extractors
      class FileExtractor < Chronicle::Etl::Extractors::Extractor
        def extract
          if file?
            extract_file do |file|
              yield file
            end
          end
        end

        def results_count
          if file?
            return 1
          else

          end
        end

        private

        def extract_from_directory
        end

        def extract_file
          file = File.open(@options[:filename])
          yield file.read
        end

        def directory?
          Pathname.new(@options[:filename]).directory?
        end

        def file?
          Pathname.new(@options[:filename]).file?
        end
      end
    end
  end
end
