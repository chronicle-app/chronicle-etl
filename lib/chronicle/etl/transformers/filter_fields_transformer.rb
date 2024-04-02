# frozen_string_literal: true

module Chronicle
  module ETL
    # A transformer that filters the fields of a record and returns a new hash with only the specified fields.
    class FilterFieldsTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :filter_fields
        r.description = 'by taking a subset of the fields'
      end

      setting :fields, type: :array, default: []

      def transform(record)
        hash = record.data.to_h.deep_transform_keys(&:to_sym)
        filter_hash(hash, @config.fields.map)
      end

      private

      def access_nested_value(data, path)
        keys = path.split('.')
        keys.reduce(data) do |acc, key|
          if acc.is_a?(Array)
            acc.map do |item|
              item[key.to_sym]
            rescue StandardError
              nil
            end
              .compact
          elsif key.include?('[')
            key, index = key.split(/\[|\]/).reject(&:empty?)
            acc = acc[key.to_sym] if acc
            acc.is_a?(Array) ? acc[index.to_i] : nil
          else
            acc&.dig(key.to_sym)
          end
        end
      end

      def filter_hash(original_hash, fields)
        fields.each_with_object({}) do |field, result|
          value = access_nested_value(original_hash, field)
          keys = field.split('.')
          last_key = keys.pop.to_sym

          current = result
          keys.each do |key|
            key = key.to_sym
            key, = key.to_s.split(/\[|\]/) if key.to_s.include?('[')
            current[key] ||= {}
            current = current[key]
          end

          current[last_key] = value
        end
      end
    end
  end
end
