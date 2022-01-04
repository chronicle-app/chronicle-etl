module Chronicle
  module ETL
    # Abstract class representing a Serializer for an ETL record
    class Serializer
      extend Chronicle::ETL::Catalog

      # Construct a new instance of this serializer.
      # == Parameters:
      # options::
      #   Options for configuring this Serializers
      def initialize(record, options = {})
        @record = record
        @options = options
      end

      # Serialize a record as a hash
      def serializable_hash
        raise NotImplementedError
      end

      def self.serialize(record)
        serializer = self.new(record)
        serializer.serializable_hash
      end
    end
  end
end

require_relative 'jsonapi_serializer'