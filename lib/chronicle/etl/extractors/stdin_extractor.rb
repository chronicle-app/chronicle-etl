module Chronicle
  module Etl
    class StdinExtractor < Chronicle::Etl::Extractor
      def extract
        $stdin.read.each_line do |line|
          yield line
        end
      end
    end
  end
end
