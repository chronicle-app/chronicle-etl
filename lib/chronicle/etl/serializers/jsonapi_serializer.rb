module Chronicle
  module ETL
    class JSONAPISerializer < Chronicle::ETL::Serializer
      def serializable_hash
        @record
          .identifier_hash
          .merge({ attributes: @record.attributes })
          .merge({ relationships: build_associations })
          .merge(@record.meta_hash)
      end

      def build_associations
        @record.associations.transform_values do |value|
          association_data =
            if value.is_a?(Array)
              value.map { |record| JSONAPISerializer.new(record).serializable_hash }
            else
              JSONAPISerializer.new(value).serializable_hash
            end
          { data: association_data }
        end
      end
    end
  end
end
