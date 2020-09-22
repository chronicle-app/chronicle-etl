module Chronicle
  module ETL
    module Utils
      module JSONAPI
        # For a given Chronicle::ETL::Model, serialize it as jsonapi
        def self.serialize(record)
          return unless record.is_a? Chronicle::ETL::Models::Base

          obj = record.identifier_hash
          obj[:attributes] = record.attributes

          relationships = Hash[record.associations.map do |k, v|
            if v.is_a?(Array)
              data = { data: v.map{ |association| serialize(association) } }
            else
              data = { data: serialize(v) }
            end

            [k, data]
          end]

          obj[:relationships] = relationships if relationships.any?
          obj
        end
      end
    end
  end
end
