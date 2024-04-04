# frozen_string_literal: true

require 'rubygems'
require 'rubygems/command'
require 'rubygems/commands/install_command'
require 'rubygems/uninstaller'
require 'gems'
require 'active_support/core_ext/hash/deep_merge'

module Chronicle
  module ETL
    module Registry
      # Responsible for managing plugins available to chronicle-etl
      #
      # @todo Better validation for whether a gem is actually a plugin
      # @todo Add ways to load a plugin that don't require a gem on rubygems.org
      module Plugins
        KNOWN_PLUGINS = %w[
          apple-podcasts
          email
          foursquare
          github
          imessage
          pinboard
          safari
          shell
          spotify
          zulip
        ].freeze
        public_constant :KNOWN_PLUGINS

        # Start of a system for having non-gem plugins. Right now, we just
        # make registry aware of existence of name of non-gem plugin
        def self.register_standalone(name:)
          plugin = Chronicle::ETL::Registry::PluginRegistration.new do |p|
            p.name = name.to_sym
            p.installed = true
          end

          installed_standalone << plugin
        end

        # Plugins either installed as gems or manually loaded/registered
        def self.installed
          installed_standalone + installed_as_gem
        end

        # Check whether a given plugin is installed
        def self.installed?(name)
          installed.map(&:name).include?(name.to_sym)
        end

        # List of plugins installed as standalone
        def self.installed_standalone
          @standalones ||= []
        end

        # List of plugins installed as gems
        def self.installed_as_gem
          installed_gemspecs_latest.map do |gem|
            Chronicle::ETL::Registry::PluginRegistration.new do |p|
              p.name = gem.name.sub('chronicle-', '').to_sym
              p.gem = gem.name
              p.description = gem.description
              p.version = gem.version.to_s
              p.installed = true
            end
          end
        end

        # List of all plugins available to chronicle-etl
        def self.available
          available_as_gem
        end

        # List of plugins available through rubygems
        # TODO: make this concurrent
        def self.available_as_gem
          KNOWN_PLUGINS.map do |name|
            info = gem_info(name)
            Chronicle::ETL::Registry::PluginRegistration.new do |p|
              p.name = name
              p.gem = info['name']
              p.version = info['version']
              p.description = info['info']
            end
          end
        end

        # Load info about a gem plugin from rubygems API
        def self.gem_info(name)
          gem_name = "chronicle-#{name}"
          Gems.info(gem_name)
        end

        # Union of installed gems (latest version) + available gems
        def self.all
          (installed + available)
            .group_by(&:name)
            .transform_values { |plugin| plugin.find(&:installed) || plugin.first }
            .values
        end

        # Does a plugin with a given name exist?
        def self.exists?(name)
          KNOWN_PLUGINS.include?(name)
        end

        # All versions of all plugins currently installed
        def self.installed_gemspecs
          # TODO: add check for chronicle-etl dependency
          Gem::Specification.filter do |s|
            s.name.match(/^chronicle-/) && s.name != 'chronicle-etl' && s.name != 'chronicle-core'
          end
        end

        # Latest version of each installed plugin
        def self.installed_gemspecs_latest
          installed_gemspecs.group_by(&:name)
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
        rescue StandardError, LoadError => e
          # StandardError to catch random non-loading problems that might occur
          # when requiring the plugin (eg class macro invoked the wrong way)
          # TODO: decide if this should be separated
          raise Chronicle::ETL::PluginLoadError.new(name), "Plugin '#{name}' couldn't be loaded"
        end

        # Install a plugin to local gems
        def self.install(name)
          return if installed?(name)
          raise(Chronicle::ETL::PluginNotAvailableError.new(name), "Plugin #{name} doesn't exist") unless exists?(name)

          gem_name = "chronicle-#{name}"

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
