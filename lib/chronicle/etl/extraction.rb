# frozen_string_literal: true

module Chronicle
  module ETL
    class Extraction
      attr_accessor :data, :meta, :source, :type, :strategy, :extractor

      def initialize(data: {}, meta: {}, source: nil, type: nil, strategy: nil, extractor: nil)
        @data = data
        @meta = meta
        @source = source
        @type = type
        @strategy = strategy
        @extractor = extractor
      end

      def to_h
        { data: @data, meta: @meta, source: @source }
      end
    end
  end
end
