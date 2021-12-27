module Chronicle
  module ETL
    class StdinExtractor < Chronicle::ETL::Extractor
      def extract
        $stdin.read.each_line do |line|
          data = { line: line.strip }
          yield Chronicle::ETL::Extraction.new(data: data)
        end
      end
    end
  end
end
