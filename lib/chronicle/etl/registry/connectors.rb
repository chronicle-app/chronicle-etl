# frozen_string_literal: true

require 'rubygems'

module Chronicle
  module ETL
    module Registry
      # A singleton class that acts as a registry of connector classes available for ETL jobs
      module Connectors
        PHASES = %i[extractor transformer loader].freeze
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

        def self.ancestor_for_phase(phase)
          case phase
          when :extractor
            Chronicle::ETL::Extractor
          when :transformer
            Chronicle::ETL::Transformer
          when :loader
            Chronicle::ETL::Loader
          end
        end

        def self.find_converter_for_source(source:, type: nil, strategy: nil, target: nil)
          # FIXME: we're assuming extractor plugin has been loaded already
          # This may not be the case if the schema converter is running
          # off a json dump off extraction data.
          # plugin = source_klass.connector_registration.source
          # type = source_klass.connector_registration.type
          # strategy = source_klass.connector_registration.strategy

          connectors.find do |c|
            c.phase == :transformer &&
              c.source == source &&
              (type.nil? || c.type == type) &&
              (strategy.nil? || c.strategy == strategy) &&
              (target.nil? || c.to_schema == target)
          end
        end

        # Find connector from amongst those currently loaded
        def self.find_by_phase_and_identifier_built_in(phase, identifier)
          connectors.find { |c| c.phase == phase.to_sym && c.identifier == identifier.to_sym }
        end

        # Find connector and load relevant plugin to find it if necessary
        def self.find_by_phase_and_identifier(phase, identifier)
          connector = find_by_phase_and_identifier_built_in(phase, identifier)
          return connector if connector

          # determine if we need to try to load a local file. if it has a dot in the identifier, we treat it as a file
          return find_by_phase_and_identifier_local(phase, identifier) if identifier.to_s.include?('.')

          # Example identifier: lastfm:listens:api
          plugin, type, strategy = identifier.split(':')
            .map { |part| part.gsub('-', '_') }
            .map(&:to_sym)

          plugin_identifier = plugin.to_s.gsub('_', '-')

          unless Chronicle::ETL::Registry::Plugins.installed?(plugin_identifier)
            raise Chronicle::ETL::PluginNotInstalledError, plugin_identifier
          end

          Chronicle::ETL::Registry::Plugins.activate(plugin_identifier)

          # find most specific connector that matches the identifier
          connector = connectors.find do |c|
            c.plugin == plugin && (type.nil? || c.type == type) && (strategy.nil? || c.strategy == strategy)
          end

          connector || raise(ConnectorNotAvailableError, "Connector '#{identifier}' not found")
        end

        # Load a plugin from local file system
        def self.find_by_phase_and_identifier_local(phase, identifier)
          script = File.read(identifier)
          raise ConnectorNotAvailableError, "Connector '#{identifier}' not found" if script.nil?

          # load the file by evaluating the contents
          eval(script, TOPLEVEL_BINDING, __FILE__, __LINE__) # rubocop:disable Security/Eval

          # read the file and look for all class definitions in the ruby script.
          class_names = script.scan(/class (\w+)/).flatten

          class_names.each do |class_name|
            klass = Object.const_get(class_name)

            next unless klass.ancestors.include?(ancestor_for_phase(phase))

            registration = ::Chronicle::ETL::Registry::ConnectorRegistration.new(klass)

            klass.connector_registration = registration
            return registration
            # return klass
          rescue NameError
            # ignore
          end

          raise ConnectorNotAvailableError, "Connector '#{identifier}' not found"
        end
      end
    end
  end
end
