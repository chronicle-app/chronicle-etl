# frozen_string_literal: true

require 'chronicle/etl'

module Chronicle
  module ETL
    # Abstract class representing an Extractor for an ETL job
    class Extractor
      extend Chronicle::ETL::Registry::SelfRegistering
      include Chronicle::ETL::Configurable

      setting :since, type: :time
      setting :until, type: :time
      setting :limit, type: :numeric
      setting :load_after_id
      setting :input

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

      protected

      def build_extraction(data:, meta: nil, source: nil, type: nil, strategy: nil)
        Extraction.new(
          extractor: self.class,
          data: data,
          meta: meta,
          source: source || self.class.connector_registration.source,
          type: type || self.class.connector_registration.type,
          strategy: strategy || self.class.connector_registration.strategy
        )
      end

      # TODO: reimplemenet this
      # def handle_continuation
      #   return unless @config.continuation

      #   @config.since = @config.continuation.highest_timestamp if @config.continuation.highest_timestamp
      #   @config.load_after_id = @config.continuation.last_id if @config.continuation.last_id
      # end
    end
  end
end

require_relative 'helpers/input_reader'
require_relative 'csv_extractor'
require_relative 'file_extractor'
require_relative 'json_extractor'
require_relative 'stdin_extractor'
