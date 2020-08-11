module Chronicle
  module Etl
    module Extractors
      class Extractor
        def initialize(options = {})
          @options = options.transform_keys!(&:to_sym) 
        end

        def extract
          raise NotImplementedError
        end

        def results_count; end
      end
    end
  end
end

require_relative 'stdin_extractor'
require_relative 'csv_extractor'
require_relative 'file_extractor'