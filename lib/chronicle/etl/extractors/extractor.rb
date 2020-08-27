require 'chronicle/etl'

module Chronicle
  module ETL
    # Abstract class representing an Extractor for an ETL job
    class Extractor
      extend Chronicle::ETL::Catalog

      # Construct a new instance of this extractor. Options are passed in from a Runner
      # == Paramters:
      # options::
      #   Options for configuring this Extractor
      def initialize(options = {})
        @options = options.transform_keys!(&:to_sym)
      end

      # Entrypoint for this Extractor. Called by a Runner. Expects a series of records to be yielded
      def extract
        raise NotImplementedError
      end

      # An optional method to calculate how many records there are to extract. Used primarily for
      # building the progress bar
      def results_count; end
    end
  end
end

require_relative 'csv_extractor'
require_relative 'file_extractor'
require_relative 'stdin_extractor'
