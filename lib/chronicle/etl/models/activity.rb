require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      class Activity < Chronicle::ETL::Models::Base
        TYPE = 'activities'.freeze
        ATTRIBUTES = [:verb, :start_at, :end_at].freeze
        ASSOCIATIONS = [:involved, :actor].freeze

        attr_accessor(*ATTRIBUTES, *ASSOCIATIONS)
      end
    end
  end
end
