# frozen_string_literal: true

module Chronicle
  module ETL
    class SortTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :sort
        r.description = 'sorts records by a given field'
      end

      setting :key, required: true, default: 'id'
      setting :direction, required: false, default: 'desc'

      def transform(record)
        stash_record(record)
      end

      def finish
        return unless @stashed_records&.any?

        sorted = @stashed_records.sort_by do |record|
          value = record.data[@config.key]
          value.nil? ? [1] : [0, value]
        end

        sorted.reverse! if @config.direction == 'desc'
        sorted
      end
    end
  end
end
