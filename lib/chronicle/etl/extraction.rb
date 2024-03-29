# frozen_string_literal: true

module Chronicle
  module ETL
    class Extraction
      attr_accessor :data, :meta, :source

      def initialize(data: {}, meta: {}, source: nil)
        @data = data
        @meta = meta
        @source = source
      end

      def to_h
        { data: @data, meta: @meta, source: @source }
      end
    end
  end
end
