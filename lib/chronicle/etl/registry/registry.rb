module Chronicle
  module ETL
    module Registry
    end
  end
end

require_relative 'self_registering'
require_relative 'connector_registration'
require_relative 'connectors'
require_relative 'plugin_registration'
require_relative 'plugins'
