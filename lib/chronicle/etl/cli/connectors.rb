module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL connectors
      class Connectors < SubcommandBase
        default_task 'list'
        namespace :connectors

        desc "install NAME", "Installs connector NAME"
        def install(name)
          Chronicle::ETL::Registry.install_connector(name)
        end

        desc "list", "Lists available connectors"
        # Display all available connectors that chronicle-etl has access to
        def list
          Chronicle::ETL::Registry.load_all!

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
      end
    end
  end
end
