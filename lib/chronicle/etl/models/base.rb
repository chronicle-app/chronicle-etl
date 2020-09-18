require 'digest'

module Chronicle
  module ETL
    module Models
      # Represents a record that's been transformed by a Transformer and
      # ready to be loaded. Loosely based on ActiveModel.
      class Base
        ATTRIBUTES = [:provider, :provider_id, :lat, :lng].freeze
        ASSOCIATIONS = [].freeze

        attr_accessor(:id, :dedupe_on, *ATTRIBUTES)

        def initialize(attributes = {})
          assign_attributes(attributes) if attributes
          @dedupe_on = []
        end

        # A unique identifier for this model is formed from a type
        # and either an id or lids.
        def identifier_hash
          {
            type: self.class::TYPE,
            id: @id,
            lids: lids
          }.compact
        end

        # Array of local ids that uniquely identify this record
        def lids
          @dedupe_on.map do |fields|
            generate_lid(fields)
          end.compact.uniq
        end

        # For a given set of fields of this model, generate a
        # unique local id by hashing the field values
        def generate_lid fields
          values = fields.sort.map do |field|
            instance_variable = "@#{field.to_s}"
            self.instance_variable_get(instance_variable)
          end

          return if values.any? { |e| e.nil? }

          Digest::SHA256.hexdigest(values.join(","))
        end

        # Set of attribute names that this model has is Base's shared
        # attributes combined with the child class's
        def attribute_list
          (ATTRIBUTES + self.class::ATTRIBUTES).uniq
        end

        # All of this record's attributes
        def attributes
          attributes = {}
          attribute_list.each do |attribute|
            instance_variable = "@#{attribute.to_s}"
            attributes[attribute] = self.instance_variable_get(instance_variable)
          end
          attributes.compact
        end

        # All of this record's associations
        def associations
          association_list = ASSOCIATIONS + self.class::ASSOCIATIONS
          attributes = {}
          association_list.each do |attribute|
            instance_variable = "@#{attribute.to_s}"
            association = self.instance_variable_get(instance_variable)
            attributes[attribute] = association if association
          end
          attributes.compact
        end

        def associations_hash
          Hash[associations.map do |k, v|
            [k, v.to_h]
          end]
        end

        # FIXME: move this to a Utils module
        def to_h_flattened
          Chronicle::ETL::Utils::HashUtilities.flatten_hash(to_h)
        end

        def to_h
          identifier_hash.merge(attributes).merge(associations_hash)
        end

        private

        def assign_attributes attributes
          attributes.each do |k, v|
            setter = :"#{k}="
            public_send(setter, v) if respond_to? setter
          end
        end
      end
    end
  end
end
