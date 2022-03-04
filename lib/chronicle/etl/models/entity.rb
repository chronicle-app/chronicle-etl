require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      class Entity < Chronicle::ETL::Models::Base
        TYPE = 'entities'.freeze
        ATTRIBUTES = [:title, :body, :provider_url, :represents, :slug, :myself, :metadata].freeze

        # TODO: This desperately needs a validation system
        ASSOCIATIONS = [
          :involvements, # inverse of activity's `involved`

          :attachments,
          :abouts,
          :aboutables, # inverse of above
          :depicts,
          :consumers,
          :contains,
          :containers # inverse of above
        ].freeze  # TODO: add these to reflect Chronicle Schema

        attr_accessor(*ATTRIBUTES, *ASSOCIATIONS)
      end
    end
  end
end
