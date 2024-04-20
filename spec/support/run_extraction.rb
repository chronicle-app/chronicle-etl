module Chronicle
  module ETL
    module SpecHelpers
      def run_extraction(klass, options = {})
        extractor = klass.new(options)
        extractor.prepare
        results = []
        extractor.extract do |extraction|
          results << extraction
        end
        results
      end
    end
  end
end
