# frozen_string_literal: true

module Chronicle
  module ETL
    # Return only records that match all the conditions of the filters
    # setting.
    class FilterTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :filter
        r.description = 'by only accepting records that match conditions'
      end

      setting :filters, type: :hash

      def transform(record)
        record_hash = record.data.to_h

        @config.filters.each do |key, value|
          path = key.split('.').map do |k|
            k.match?(/^\d+$/) ? k.to_i : k.to_sym
          end

          return nil unless record_hash.dig(*path) == value
        end

        record.data
      end
    end
  end
end
