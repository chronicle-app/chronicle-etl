module Chronicle
  module ETL
    class StdinExtractor < Chronicle::ETL::Extractor
      def extract
        $stdin.read.each_line do |line|
          yield line
        end
      end
    end
  end
end
