require 'rubygems'
require 'rubygems/command'
require 'rubygems/commands/install_command'
require 'rubygems/uninstaller'

module Chronicle
  module ETL
    module Registry
      # Responsible for managing plugins available to chronicle-etl
      #
      # @todo Better validation for whether a gem is actually a plugin
      # @todo Add ways to load a plugin that don't require a gem on rubygems.org
      module PluginRegistry
        # Does this plugin exist?
        def self.exists?(name)
          # TODO: implement this. Could query rubygems.org or have a
          # hardcoded approved list
          true
        end

        # All versions of all plugins currently installed
        def self.all_installed
          # TODO: add check for chronicle-etl dependency
          Gem::Specification.filter { |s| s.name.match(/^chronicle-/) && s.name != "chronicle-etl" }
        end

        # Latest version of each installed plugin
        def self.all_installed_latest
          all_installed.group_by(&:name)
            .transform_values { |versions| versions.sort_by(&:version).reverse.first }
            .values
        end

        # Activate a plugin with given name by `require`ing it
        def self.activate(name)
          # By default, activates the latest available version of a gem
          # so don't have to run Kernel#gem separately
          require "chronicle/#{name}"
        rescue Gem::ConflictError => e
          # TODO: figure out if there's more we can do here
          raise Chronicle::ETL::PluginConflictError.new(name), "Plugin '#{name}' couldn't be loaded. #{e.message}"
        rescue LoadError => e
          raise Chronicle::ETL::PluginLoadError.new(name), "Plugin '#{name}' couldn't be loaded" if exists?(name)

          raise Chronicle::ETL::PluginNotAvailableError.new(name), "Plugin #{name} doesn't exist"
        end

        # Install a plugin to local gems
        def self.install(name)
          gem_name = "chronicle-#{name}"
          raise(Chronicle::ETL::PluginNotAvailableError.new(gem_name), "Plugin #{name} doesn't exist") unless exists?(gem_name)

          Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
          Gem.install(gem_name)

          activate(name)
        rescue Gem::UnsatisfiableDependencyError
          # TODO: we need to catch a lot more than this here
          raise Chronicle::ETL::PluginNotAvailableError.new(name), "Plugin #{name} could not be installed."
        end

        # Uninstall a plugin
        def self.uninstall(name)
          gem_name = "chronicle-#{name}"
          Gem::DefaultUserInteraction.ui = Gem::SilentUI.new
          uninstaller = Gem::Uninstaller.new(gem_name)
          uninstaller.uninstall
        rescue Gem::InstallError
          # TODO: strengthen this exception handling
          raise(Chronicle::ETL::PluginError.new(name), "Plugin #{name} wasn't uninstalled")
        end
      end
    end
  end
end
