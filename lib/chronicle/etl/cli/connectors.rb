module Chronicle
  module Etl
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
          klasses = Chronicle::Etl::Catalog.available_classes
          klasses = klasses.sort_by do |a|
            [a[:built_in].to_s, a[:provider], a[:phase]]
          end

          headers = klasses.first.keys.map do |key|
            key.to_s.upcase.bold
          end

          table = TTY::Table.new(headers, klasses.map(&:values))
          puts table.render(indent: 0, padding: [0, 2])
        end
      end
    end
  end
end
