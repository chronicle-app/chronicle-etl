require 'pathname'

module Chronicle
  module ETL
    class FileExtractor < Chronicle::ETL::Extractor
      def extract
        if file?
          extract_file do |data, metadata|
            yield(data, metadata)
          end
        elsif directory?
          extract_from_directory do |data, metadata|
            yield(data, metadata)
          end
        end
      end

      def results_count
        if file?
          return 1
        else
          search_pattern = File.join(@options[:filename], '**/*.eml')
          Dir.glob(search_pattern).count
        end
      end

      private

      def extract_from_directory
        search_pattern = File.join(@options[:filename], '**/*.eml')
        filenames = Dir.glob(search_pattern)
        filenames.each do |filename|
          file = File.open(filename)
          yield(file.read, {filename: file})
        end
      end

      def extract_file
        file = File.open(@options[:filename])
        yield(file.read, {filename: @options[:filename]})
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
