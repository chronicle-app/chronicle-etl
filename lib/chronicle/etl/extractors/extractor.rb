require 'chronicle/etl'

module Chronicle
  module ETL
    # Abstract class representing an Extractor for an ETL job
    class Extractor
      extend Chronicle::ETL::Registry::SelfRegistering

      # Construct a new instance of this extractor. Options are passed in from a Runner
      # == Paramters:
      # options::
      #   Options for configuring this Extractor
      def initialize(options = {})
        @options = options.transform_keys!(&:to_sym)
        sanitize_options
        handle_continuation
      end

      # Hook called before #extract. Useful for gathering data, initailizing proxies, etc
      def prepare; end

      # An optional method to calculate how many records there are to extract. Used primarily for
      # building the progress bar
      def results_count; end

      # Entrypoint for this Extractor. Called by a Runner. Expects a series of records to be yielded
      def extract
        raise NotImplementedError
      end

      private

      def sanitize_options
        @options[:load_since] = Time.parse(@options[:load_since]) if @options[:load_since] && @options[:load_since].is_a?(String)
        @options[:load_until] = Time.parse(@options[:load_until]) if @options[:load_until] && @options[:load_until].is_a?(String)
      end

      def handle_continuation
        return unless @options[:continuation]

        @options[:load_since] = @options[:continuation].highest_timestamp if @options[:continuation].highest_timestamp
        @options[:load_after_id] = @options[:continuation].last_id if @options[:continuation].last_id
      end
    end
  end
end

require_relative 'helpers/filesystem_reader'
require_relative 'csv_extractor'
require_relative 'file_extractor'
require_relative 'json_extractor'
require_relative 'stdin_extractor'
