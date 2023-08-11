module Chronicle
  module ETL
    class JSONAPISerializer < Chronicle::ETL::Serializer
      def initialize(*args)
        super

        raise(SerializationError, "Record must be a subclass of Chronicle::Schema::Base") unless @record.is_a?(Chronicle::Schema::Base)
      end

      def serializable_hash
        @record.to_h_jsonapi
      end
    end
  end
end
