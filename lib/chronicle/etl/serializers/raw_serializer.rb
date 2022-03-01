module Chronicle
  module ETL
    # Take a Raw model and output `raw_data` as a hash
    class RawSerializer < Chronicle::ETL::Serializer
      def serializable_hash
        @record.to_h
      end
    end
  end
end
