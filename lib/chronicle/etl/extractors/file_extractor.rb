require 'pathname'

module Chronicle
  module ETL
    class FileExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::FilesystemReader

      register_connector do |r|
        r.description = 'file or directory of files'
      end

      def extract
        open_files_in_directory(
          path: @options[:filename],
          dir_glob_pattern: @options[:dir_glob_pattern],
          load_since: @options[:load_since],
          load_until: @options[:load_until]
        ) do |file|
          yield Chronicle::ETL::Extraction.new(data: file)
        end
      end

      def results_count
      end
    end
  end
end
