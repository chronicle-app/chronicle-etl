module Chronicle
  module Etl
    class Transformer
      include Chronicle::Etl::Cataloguer
      ETL_PHASE = :transformer
      
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
