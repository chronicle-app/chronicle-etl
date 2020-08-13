require 'chronicle/etl'

module Chronicle
  module Etl
    class Extractor
      extend Chronicle::Etl::Catalog

      ETL_PHASE = :extractor

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

require_relative 'csv_extractor'
require_relative 'file_extractor'
require_relative 'stdin_extractor'
