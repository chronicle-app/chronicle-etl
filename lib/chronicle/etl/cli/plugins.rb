# frozen_string_literal: true

require "tty-prompt"
require "tty-spinner"


module Chronicle
  module ETL
    module CLI
      # CLI commands for working with ETL plugins
      class Plugins < SubcommandBase
        default_task 'list'
        namespace :plugins

        desc "install", "Install a plugin"
        def install(name)
          spinner = TTY::Spinner.new("[:spinner] Installing plugin #{name}...", format: :dots_2)
          spinner.auto_spin
          Chronicle::ETL::Registry::PluginRegistry.install(name)
          spinner.success("(#{'successful'.green})")
        rescue Chronicle::ETL::PluginError => e
          spinner.error("Error".red)
          cli_fail(message: "Plugin '#{name}' could not be installed", exception: e)
        end

        desc "uninstall", "Unintall a plugin"
        def uninstall(name)
          spinner = TTY::Spinner.new("[:spinner] Uninstalling plugin #{name}...", format: :dots_2)
          spinner.auto_spin
          Chronicle::ETL::Registry::PluginRegistry.uninstall(name)
          spinner.success("(#{'successful'.green})")
        rescue Chronicle::ETL::PluginError => e
          spinner.error("Error".red)
          cli_fail(message: "Plugin '#{name}' could not be uninstalled (was it installed?)", exception: e)
        end

        desc "list", "Lists available plugins"
        # Display all available plugins that chronicle-etl has access to
        def list
          plugins = Chronicle::ETL::Registry::PluginRegistry.all_installed_latest

          info = plugins.map do |plugin|
            {
              name: plugin.name.sub("chronicle-", ""),
              description: plugin.description,
              version: plugin.version
            }
          end

          headers = ['name', 'description', 'latest version'].map{ |h| h.to_s.upcase.bold }
          table = TTY::Table.new(headers, info.map(&:values))
          puts "Installed plugins:"
          puts table.render(indent: 2, padding: [0, 0])
        end
      end
    end
  end
end
