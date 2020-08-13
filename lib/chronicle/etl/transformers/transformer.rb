module Chronicle
  module Etl
    class Transformer
      extend Chronicle::Etl::Catalog

      def initialize(options = {})
        @options = options
      end

      def transform data
        raise NotImplementedError
      end
    end
  end
end

require_relative 'json_transformer'
require_relative 'null_transformer'
