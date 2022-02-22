require 'pathname'

module Chronicle
  module ETL
    class FileExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::FilesystemReader

      register_connector do |r|
        r.description = 'file or directory of files'
      end

      # TODO: consolidate this with @config.filename
      setting :dir_glob_pattern

      def extract
        filenames.each do |filename|
          yield Chronicle::ETL::Extraction.new(data: filename)
        end
      end

      def results_count
        filenames.count
      end

      private

      def filenames
        @filenames ||= filenames_in_directory(
          path: @config.filename,
          dir_glob_pattern: @config.dir_glob_pattern,
          load_since: @config.since,
          load_until: @config.until
        )
      end
    end
  end
end
