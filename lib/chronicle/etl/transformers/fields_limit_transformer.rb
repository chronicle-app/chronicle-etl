# frozen_string_literal: true

require 'chronicle/utils/hash_utils'

module Chronicle
  module ETL
    # A transformer that filters the fields of a record and returns a new hash with only the specified fields.
    class FieldsLimitTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :fields_limit
        r.description = 'by taking first N fields'
      end

      setting :limit, type: :numeric, default: 10

      def transform(record)
        # flattern hash and then take the first limit fields

        Chronicle::Utils::HashUtils.flatten_hash(record.data.to_h).first(@config.limit).to_h
      end
    end
  end
end
