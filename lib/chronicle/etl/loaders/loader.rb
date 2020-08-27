module Chronicle
  module ETL
    # Abstract class representing a Loader for an ETL job
    class Loader
      extend Chronicle::ETL::Catalog

      # Construct a new instance of this loader. Options are passed in from a Runner
      # == Paramters:
      # options::
      #   Options for configuring this Loader
      def initialize(options = {})
        @options = options
      end

      # Called once before processing records
      def start; end

      # Load a single record
      def load
        raise NotImplementedError
      end

      # Called once there are no more records to process
      def finish; end
    end
  end
end

require_relative 'csv_loader'
require_relative 'stdout_loader'
require_relative 'table_loader'
