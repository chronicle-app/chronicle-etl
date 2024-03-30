# frozen_string_literal: true

require 'rubygems'

module Chronicle
  module ETL
    module Registry
      # A singleton class that acts as a registry of connector classes available for ETL jobs
      module Connectors
        PHASES = [:extractor, :transformer, :loader].freeze
        public_constant :PHASES

        class << self
          attr_accessor :connectors
        end

        def self.register(connector)
          connectors << connector
        end

        def self.connectors
          @connectors ||= []
        end

        def self.find_converter_for_source(source_klass, _target)
          # FIXME: we're assuming extractor plugin has been loaded already
          plugin = source_klass.connector_registration.source
          type = source_klass.connector_registration.type
          strategy = source_klass.connector_registration.strategy

          connectors.find do |c|
            c.phase == :transformer &&
              c.plugin == plugin &&
              (type.nil? || c.type == type) &&
              (strategy.nil? || c.strategy == strategy)
          end
        end

        # Find connector from amongst those currently loaded
        def self.find_by_phase_and_identifier_local(phase, identifier)
          connector = connectors.find { |c| c.phase == phase && c.identifier == identifier }
        end

        # Find connector and load relevant plugin to find it if necessary
        def self.find_by_phase_and_identifier(phase, identifier)
          connector = find_by_phase_and_identifier_local(phase, identifier.to_sym)
          return connector if connector

          # Example identifier: lastfm:listens:api
          plugin, type, strategy = identifier.split(':').map(&:to_sym)

          unless Chronicle::ETL::Registry::Plugins.installed?(plugin)
            raise Chronicle::ETL::PluginNotInstalledError, plugin
          end

          Chronicle::ETL::Registry::Plugins.activate(plugin)

          # find most specific connector that matches the identifier
          connector = connectors.find do |c|
            c.plugin == plugin && (type.nil? || c.type == type) && (strategy.nil? || c.strategy == strategy)
          end

          connector || raise(ConnectorNotAvailableError, "Connector '#{identifier}' not found")
        end
      end
    end
  end
end
