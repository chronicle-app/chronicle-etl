# frozen_string_literal: true

module Chronicle
  module ETL
    class NullTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :null
        r.description = 'in no way'
      end

      def transform(record)
        yield record.data
      end
    end
  end
end
