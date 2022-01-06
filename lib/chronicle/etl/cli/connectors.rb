module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL connectors
      class Connectors < SubcommandBase
        default_task 'list'
        namespace :connectors

        desc "install NAME", "Installs connector NAME"
        def install
          puts "Installing"
        end

        desc "list", "Lists available connectors"
        # Display all available connectors that chronicle-etl has access to
        def list
          connector_info = Chronicle::ETL::Catalog.available_classes.map do |klass|
            {
              identifier: klass.identifier,
              phase: klass.phase,
              description: klass.descriptive_phrase,
              provider: klass.provider,
              core: klass.built_in? ? '✓' : '',
              class: klass.name
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
