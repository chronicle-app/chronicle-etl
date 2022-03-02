require 'pathname'

module Chronicle
  module ETL
    # Return filenames that match a pattern in a directory
    class FileExtractor < Chronicle::ETL::Extractor

      register_connector do |r|
        r.description = 'file or directory of files'
      end

      setting :input, default: ['.']
      setting :dir_glob_pattern, default: "**/*"
      setting :larger_than
      setting :smaller_than

      def prepare
        @pathnames = gather_files
      end

      def extract
        @pathnames.each do |pathname|
          yield Chronicle::ETL::Extraction.new(data: pathname.to_path)
        end
      end

      def results_count
        @pathnames.count
      end

      private

      def gather_files
        roots = [@config.input].flatten.map { |filename| Pathname.new(filename) }
        raise(ExtractionError, "Input must exist") unless roots.all?(&:exist?)

        directories, files = roots.partition(&:directory?)

        directories.each do |directory|
          files += Dir.glob(File.join(directory, @config.dir_glob_pattern)).map { |filename| Pathname.new(filename) }
        end

        files = files.uniq

        files = files.keep_if { |f| (f.mtime > @config.since) } if @config.since
        files = files.keep_if { |f| (f.mtime < @config.until) } if @config.until

        # pass in file sizes in bytes
        files = files.keep_if { |f| (f.size < @config.smaller_than) } if @config.smaller_than
        files = files.keep_if { |f| (f.size > @config.larger_than) } if @config.larger_than

        # # TODO: incorporate sort argument
        files.sort_by(&:mtime)
      end
    end
  end
end
