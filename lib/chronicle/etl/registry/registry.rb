require 'rubygems'

module Chronicle
  module ETL
    # A singleton class that acts as a registry of connector classes available for ETL jobs
    module Registry
      PHASES = [:extractor, :transformer, :loader]

      class << self
        attr_accessor :connectors

        def load_all!
          load_connectors_from_gems
        end

        def load_connectors_from_gems
          Gem::Specification.filter{|s| s.name.match(/^chronicle/) }.each do |gem|
            require_str = gem.name.gsub('chronicle-', 'chronicle/')
            require require_str rescue LoadError
          end
        end

        def register connector
          connectors << connector
        end

        def connectors
          @connectors ||= []
        end

        def find_by_phase_and_identifier(phase, identifier)
          # Simple case: built in connector
          connector = connectors.find { |c| c.phase == phase && c.identifier == identifier }
          return connector if connector

          # if not available in built-in connectors, try to activate a
          # relevant plugin and try again
          if identifier.include?(":")
            plugin, name = identifier.split(":")
          else
            # This case handles the case where the identifier is a 
            # shorthand (ie `imessage`) because there's only one default
            # connector.
            plugin = identifier
          end

          raise(Chronicle::ETL::PluginNotInstalledError.new(plugin)) unless PluginRegistry.installed?(plugin)

          PluginRegistry.activate(plugin)

          candidates = connectors.select { |c| c.phase == phase && c.plugin == plugin }
          # if no name given, just use first connector with right phase/plugin
          # TODO: set up a property for connectors to specify that they're the
          # default connector for the plugin
          candidates = candidates.select { |c| c.identifier == name } if name
          connector = candidates.first

          connector || raise(ConnectorNotAvailableError, "Connector '#{identifier}' not found")
        end
      end
    end
  end
end

require_relative 'self_registering'
require_relative 'connector_registration'
require_relative 'plugin_registry'
