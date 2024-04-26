# frozen_string_literal: true

module Chronicle
  module ETL
    class MergeMetaTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :merge_meta
        r.description = 'merge extraction meta fields into the record'
      end

      def transform(record)
        record.data unless record.extraction&.meta

        record.data[:_meta] = record.extraction.meta
        record.data
      end
    end
  end
end
