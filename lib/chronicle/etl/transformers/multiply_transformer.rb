# frozen_string_literal: true

module Chronicle
  module ETL
    class MultiplyTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :multiply
        r.description = 'by taking a sample'
      end

      setting :n, default: 2, type: :numeric

      # return the result, sample_size percentage of the time. otherwise nil
      def transform(record)
        @config.n.to_i.times do
          yield record.data
        end
      end
    end
  end
end
