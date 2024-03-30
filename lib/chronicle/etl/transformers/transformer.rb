# frozen_string_literal: true

module Chronicle
  module ETL
    # Abstract class representing an Transformer for an ETL job
    class Transformer
      extend Chronicle::ETL::Registry::SelfRegistering
      include Chronicle::ETL::Configurable

      attr_reader :stashed_records

      # Construct a new instance of this transformer. Options are passed in from a Runner
      # == Parameters:
      # options::
      #   Options for configuring this Transformer
      def initialize(options = {})
        apply_options(options)
      end

      # Called once for each extracted record. Can return 0 or more transformed records.
      def call(record, &block)
        raise ArgumentError, "Input must be a Chronicle::ETL::Record" unless record.is_a?(Record)

        yielded = false

        transformed_data = transform(record) do |data|
          new_record = update_data(record, data)
          block.call(new_record)

          yielded = true
        end

        return if yielded

        # Handle transformers that don't yield anything and return
        # transformed data directly. Skip nil values.
        [transformed_data].flatten.compact.each do |data|
          new_record = update_data(record, data)
          block.call(new_record)
        end
      end

      def call_finish(&block)
        remaining_records = finish
        return if remaining_records.nil?

        remaining_records.each do |record|
          block.call(record)
        end
      end

      def transform(_record)
        raise NotImplementedError, 'You must implement the transform method'
      end

      # Called once after runner has processed all records
      def finish; end

      protected

      def stash_record(record)
        @stashed_records ||= []
        @stashed_records << record
        nil
      end

      def flush_stashed_records
        @stashed_records.tap(&:clear)
      end

      def update_data(record, new_data)
        new_record = record.clone
        new_record.data = new_data
        new_record
      end
    end
  end
end

require_relative 'null_transformer'
require_relative 'sampler_transformer'
require_relative 'buffer_transformer'
require_relative 'multiply_transformer'
require_relative 'sort_transformer'
require_relative 'chronicle_transformer'
