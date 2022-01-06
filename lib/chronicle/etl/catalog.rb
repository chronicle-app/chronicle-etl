module Chronicle
  module ETL
    # Utility methods to catalogue which Extractor, Transformer, and
    # Loader connector classes are available to chronicle-etl
    module Catalog
      PHASES = [:extractor, :transformer, :loader]
      PLUGINS = ['email', 'bash']
      BUILTIN = {
        extractor: ['stdin', 'json', 'csv', 'file'],
        transformer: ['null', 'image'],
        loader: ['stdout', 'csv', 'table', 'rest']
      }.freeze

      # Return which ETL connectors are available, both built in and externally-defined
      def self.available_classes
        # TODO: have a registry of plugins

        # Attempt to load each chronicle plugin that we might know about so
        # that we can later search for subclasses to build our list of
        # available classes
        PLUGINS.each do |plugin|
          require "chronicle/#{plugin}"
        rescue LoadError
          # this will happen if the gem isn't available globally
        end

        parent_klasses = [
          ::Chronicle::ETL::Extractor,
          ::Chronicle::ETL::Transformer,
          ::Chronicle::ETL::Loader
        ]
        klasses = []
        parent_klasses.map do |parent|
          klasses += ::ObjectSpace.each_object(::Class).select { |klass| klass < parent }
        end

        klasses.map do |klass|
          {
            name: klass.name,
            built_in: klass.built_in?,
            provider: klass.provider,
            phase: klass.phase
          }
        end
      end

      # Take a phase (e, t, or l) and an identifier and return the right class
      def self.phase_and_identifier_to_klass(phase, identifier)
        Chronicle::ETL::Catalog.identifier_to_klass(phase: phase, identifier: identifier)
      end

      # For a given connector identifier, return the class (either builtin, or from a 
      # external chronicle gem)
      def self.identifier_to_klass(identifier:, phase:)
        if BUILTIN[phase].include? identifier
          load_builtin_klass(name: identifier, phase: phase)
        else
          provider, name = identifier.split(':')
          name ||= ''
          load_provider_klass(provider: provider, name: name, phase: phase)
        end
      end

      # Returns whether a class is an Extractor, Transformer, or Loader
      def phase
        ancestors = self.ancestors
        return :extractor if ancestors.include? Chronicle::ETL::Extractor
        return :transformer if ancestors.include? Chronicle::ETL::Transformer
        return :loader if ancestors.include? Chronicle::ETL::Loader
      end

      # Returns which third-party provider this connector is associated wtih
      def provider
        # TODO: needs better convention for a gem reporting its provider name
        provider = to_s.split('::')[1].downcase
        provider == 'etl' ? 'chronicle' : provider
      end

      # Returns whether this connector is a built-in one
      def built_in?
        to_s.include? 'Chronicle::ETL'
      end

      def identifier
        # FIXME: this scheme needs re-thinking to be able to name classes better. e.g. JSONLoader instead of JsonLoader
        name = to_s.split('::').last.gsub!(/(Extractor$|Loader$|Transformer$)/, '').downcase
      end

      def description
        defined?(self::DESCRIPTION) ? self::DESCRIPTION : to_s.split('::').last
      end

      def descriptive_phrase
        prefix = case phase
        when :extractor
          "Extracts from"
        when :transformer
          "Transforms into"
        when :loader
          "Loads to"
        end

        "#{prefix} #{description}"
      end

      private

      def self.load_builtin_klass(name:, phase:)
        klass_str = "Chronicle::ETL::#{name.capitalize}#{phase.capitalize}"
        begin
          Object.const_get(klass_str)
        rescue NameError => e
          raise ConnectorNotAvailableError.new("Connector not found", name: name)
        end
      end

      def self.load_provider_klass(name: '', phase:, provider:)
        begin
          require "chronicle/#{provider}"
          klass_str = "Chronicle::#{provider.capitalize}::#{name.capitalize}#{phase.capitalize}"
          Object.const_get(klass_str)
        rescue LoadError => e
          raise ProviderNotAvailableError.new("Provider '#{provider.capitalize}' could not be loaded", provider: provider)
        rescue NameError => e
          raise ProviderConnectorNotAvailableError.new("Connector '#{name}' in '#{provider}' could not be found", provider: provider, name: name)
        end
      end
    end
  end
end
