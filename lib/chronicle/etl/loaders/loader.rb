module Chronicle
  module Etl
    class Loader
      extend Chronicle::Etl::Catalog
      
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