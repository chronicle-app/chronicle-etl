require 'chronicle/etl/models/base'

module Chronicle
  module ETL
    module Models
      class Attachment < Chronicle::ETL::Models::Base
        TYPE = 'attachments'.freeze
        ATTRIBUTES = [:url_original, :data].freeze

        attr_accessor(*ATTRIBUTES)
      end
    end
  end
end
