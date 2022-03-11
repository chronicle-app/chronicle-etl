require_relative 'helpers/encoding_helper'

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

      private

      def build_headers(records)
        headers =
          if @config.fields && @config.fields.any?
            Set[*@config.fields]
          else
            # use all the keys of the flattened record hash
            Set[*records.map(&:keys).flatten.map(&:to_s).uniq]
          end

        headers = headers.delete_if { |header| header.end_with?(*@config.fields_exclude) }
        headers = headers.first(@config.fields_limit) if @config.fields_limit

        headers.to_a.map(&:to_sym)
      end
    end
  end
end

require_relative 'csv_loader'
require_relative 'json_loader'
require_relative 'rest_loader'
require_relative 'table_loader'
