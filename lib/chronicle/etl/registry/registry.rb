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

        def install_connector name
          gem_name = "chronicle-#{name}"
          Gem.install(gem_name)
        end

        def register connector
          @connectors ||= []
          @connectors << connector
        end

        def find_by_phase_and_identifier(phase, identifier)
          @connectors.find { |c| c.phase == phase && c.identifier == identifier } || raise(ConnectorNotAvailableError.new("Connector '#{identifier}' not found"))
        end
      end
    end
  end
end

require_relative 'self_registering'
require_relative 'connector_registration'
