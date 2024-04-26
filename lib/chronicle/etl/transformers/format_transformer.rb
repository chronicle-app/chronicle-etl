# frozen_string_literal: true

module Chronicle
  module ETL
    class FormatTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :format
        r.description = 'records to a differnet hash/json format'
      end

      setting :format, default: nil

      def transform(record)
        serializer = find_serializer(@config.format)
        serializer.serialize(record.data)
      end

      private

      def find_serializer(format)
        case format
        when 'jsonld'
          Chronicle::Serialization::JSONLDSerializer
        when 'jsonapi'
          Chronicle::Serialization::JSONAPISerializer
        else
          raise 'unknown format'
        end
      end
    end
  end
end
