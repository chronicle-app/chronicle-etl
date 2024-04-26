# frozen_string_literal: true

module Chronicle
  module ETL
    class BufferTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :buffer
        r.description = 'by buffering'
      end

      setting :size, default: 10, description: 'The size of the buffer'

      def transform(record)
        stash_record(record)

        # FIXME: this doesn't seem to be working with the runner
        return if @stashed_records.size < @config.size

        # FIXME: this will result in the wrong extraction being associated with
        # the batch of flushed records
        flush_stashed_records.map(&:data)
      end

      def finish
        flush_stashed_records
      end
    end
  end
end
