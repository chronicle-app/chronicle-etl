require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      class Entity < Chronicle::ETL::Models::Base
        TYPE = 'entities'.freeze
        ATTRIBUTES = [:title, :body, :represents, :slug].freeze
        ASSOCIATIONS = [].freeze  # TODO: add these to reflect Chronicle Schema

        attr_accessor(*ATTRIBUTES)
      end
    end
  end
end
