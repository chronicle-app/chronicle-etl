# frozen_string_literal: true

module Chronicle
  module ETL
    class SamplerTransformer < Chronicle::ETL::Transformer
      register_connector do |r|
        r.identifier = :sampler
        r.description = 'by taking a sample'
      end

      setting :percent, default: 10, type: :numeric

      # return the result, `percent` percentage of the time. otherwise nil
      def transform(record)
        return unless rand(100) < @config.percent

        record.data
      end
    end
  end
end
