module Chronicle
  module Etl
    module Extractors
      class StdinExtractor < Chronicle::Etl::Extractors::Extractor
        def extract
          $stdin.read.each_line do |line|
            yield line
          end
        end
      end
    end
  end
end
