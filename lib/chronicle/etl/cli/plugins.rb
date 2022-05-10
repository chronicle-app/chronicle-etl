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
        def install(*plugins)
          cli_fail(message: "Please specify a plugin to install") unless plugins.any?

          installed, not_installed = plugins.partition do |plugin|
            Chronicle::ETL::Registry::PluginRegistry.installed?(plugin)
          end

          puts "Already installed: #{installed.join(", ")}" if installed.any?
          cli_exit unless not_installed.any?

          spinner = TTY::Spinner.new("[:spinner] Installing #{not_installed.join(", ")}...", format: :dots_2)
          spinner.auto_spin

          not_installed.each do |plugin|
            spinner.update(title: "Installing #{plugin}")
            Chronicle::ETL::Registry::PluginRegistry.install(plugin)

          rescue Chronicle::ETL::PluginError => e
            spinner.error("Error".red)
            cli_fail(message: "Plugin '#{plugin}' could not be installed", exception: e)
          end

          spinner.success("(#{'successful'.green})")
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
          values = Chronicle::ETL::Registry::PluginRegistry.all
            .map do |plugin|
            [
              plugin.name, 
              plugin.description,
              plugin.installed ? '✓' : '',
              plugin.version
            ]
          end

          headers = ['name', 'description', 'installed', 'version'].map{ |h| h.to_s.upcase.bold }
          table = TTY::Table.new(headers, values)
          puts "Available plugins:"
          puts table.render(
            indent: 2,
            padding: [0, 0],
            alignments: [:left, :left, :center, :left]
          )
        end
      end
    end
  end
end
