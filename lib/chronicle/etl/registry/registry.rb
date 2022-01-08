module Chronicle
  module ETL
    # A singleton class that acts as a registry of connector classes available for ETL jobs
    module Registry
      PHASES = [:extractor, :transformer, :loader]

      class << self
        attr_accessor :connectors

        # TODO: load all ETL classes from external gems and get them to self-register

        def register connector
          @connectors ||= []
          @connectors << connector
        end

        def phase_and_identifier_to_klass(phase, identifier)
          connector = @connectors.select do |connector| 
            connector.phase == phase && connector.identifier == identifier
          end.first
          connector.klass
        end
      end
    end
  end
end

require_relative 'self_registering'
require_relative 'connector_registration'
