module Chronicle
  module Etl
    class Loader
      include Chronicle::Etl::Cataloguer
      ETL_PHASE = :loader
      def initialize(options = {})
        @options = options
      end

      def start; end

      def first_load result; end

      def load
        raise NotImplementedError
      end

      def finish; end
    end
  end
end

require_relative 'csv_loader'
require_relative 'stdout_loader'
require_relative 'table_loader'