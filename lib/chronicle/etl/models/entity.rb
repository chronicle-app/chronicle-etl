require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      class Entity < Chronicle::ETL::Models::Base
        TYPE = 'entities'.freeze
        ATTRIBUTES = [:title, :body, :represents, :slug, :myself, :metadata].freeze
        ASSOCIATIONS = [:attachments].freeze  # TODO: add these to reflect Chronicle Schema

        attr_accessor(*ATTRIBUTES, *ASSOCIATIONS)
      end
    end
  end
end
