require 'chronicle/etl'

module Chronicle
  module ETL
    # Abstract class representing an Extractor for an ETL job
    class Extractor
      extend Chronicle::ETL::Registry::SelfRegistering
      include Chronicle::ETL::Configurable

      setting :since, type: :date
      setting :until, type: :date
      setting :limit
      setting :load_after_id
      setting :filename

      # Construct a new instance of this extractor. Options are passed in from a Runner
      # == Parameters:
      # options::
      #   Options for configuring this Extractor
      def initialize(options = {})
        apply_options(options)
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

      # TODO: reimplemenet this
      # def handle_continuation
      #   return unless @config.continuation

      #   @config.since = @config.continuation.highest_timestamp if @config.continuation.highest_timestamp
      #   @config.load_after_id = @config.continuation.last_id if @config.continuation.last_id
      # end
    end
  end
end

require_relative 'helpers/filesystem_reader'
require_relative 'csv_extractor'
require_relative 'file_extractor'
require_relative 'json_extractor'
require_relative 'stdin_extractor'
