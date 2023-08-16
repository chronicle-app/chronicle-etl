require_relative 'helpers/encoding_helper'
require_relative 'helpers/stdout_helper'
require_relative 'helpers/field_filtering_helper'

module Chronicle
  module ETL
    # Abstract class representing a Loader for an ETL job
    class Loader
      extend Chronicle::ETL::Registry::SelfRegistering
      include Chronicle::ETL::Configurable
      include Chronicle::ETL::Loaders::Helpers::EncodingHelper

      setting :output
      setting :fields
      setting :fields_limit, default: nil
      setting :fields_exclude

      # Construct a new instance of this loader. Options are passed in from a Runner
      # == Parameters:
      # options::
      #   Options for configuring this Loader
      def initialize(options = {})
        apply_options(options)
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
require_relative 'json_loader'
require_relative 'rest_loader'
require_relative 'table_loader'
