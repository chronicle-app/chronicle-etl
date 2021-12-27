require 'pathname'

module Chronicle
  module ETL
    class FileExtractor < Chronicle::ETL::Extractor
      include Extractors::Helpers::FilesystemReader

      def extract
        read_from_filesystem(filename: @options[:filename]) do |data|
          yield Chronicle::ETL::Extraction.new(data: data)
        end
      end
    end
  end
end
