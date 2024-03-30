# frozen_string_literal: true

module Chronicle
  module ETL
    class ChronicleTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :chronicle
        r.description = 'convert to Chronicle schema'
      end

      def transform(record)
        converter_klass = find_converter(record.extraction)
        converter_klass.new.call(record) do |transformed_record|
          yield transformed_record.data
        end
      end

      private

      def find_converter(extraction)
        source_klass = extraction.extractor

        Chronicle::ETL::Registry::Connectors.find_converter_for_source(source_klass, :chronicle).klass
      end
    end
  end
end
