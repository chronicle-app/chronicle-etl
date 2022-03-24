# frozen_string_literal: true

module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL connectors
      #
      # @todo make this work with new plugin system (i.e. no loading of all plugins)
      class Connectors < SubcommandBase
        default_task 'list'
        namespace :connectors

        desc "list", "Lists available connectors"
        # Display all available connectors that chronicle-etl has access to
        def list
          connector_info = Chronicle::ETL::Registry.connectors.map do |connector_registration|
            {
              identifier: connector_registration.identifier,
              phase: connector_registration.phase,
              description: connector_registration.descriptive_phrase,
              provider: connector_registration.provider,
              core: connector_registration.built_in? ? '✓' : '',
              class: connector_registration.klass_name
            }
          end

          connector_info = connector_info.sort_by do |a|
            [a[:core].to_s, a[:provider], a[:phase], a[:identifier]]
          end

          headers = connector_info.first.keys.map do |key|
            key.to_s.upcase.bold
          end

          table = TTY::Table.new(headers, connector_info.map(&:values))
          puts table.render(indent: 0, padding: [0, 2])
        end

        desc "show PHASE IDENTIFIER", "Show information about a connector"
        def show(phase, identifier)
          unless ['extractor', 'transformer', 'loader'].include?(phase)
            cli_fail(message: "Phase argument must be one of: [extractor, transformer, loader]")
          end

          begin
            connector = Chronicle::ETL::Registry.find_by_phase_and_identifier(phase.to_sym, identifier)
          rescue Chronicle::ETL::ConnectorNotAvailableError, Chronicle::ETL::PluginError => e
            cli_fail(message: "Could not find #{phase} #{identifier}", exception: e)
          end

          puts connector.klass.to_s.bold
          puts "  #{connector.descriptive_phrase}"
          puts
          puts "Settings:"

          headers = ['name', 'default', 'required'].map{ |h| h.to_s.upcase.bold }

          settings = connector.klass.settings.map do |name, setting|
            [
              name,
              setting.default,
              setting.required ? 'yes' : 'no'
            ]
          end
          table = TTY::Table.new(headers, settings)
          puts table.render(indent: 0, padding: [0, 2])
        end
      end
    end
  end
end
