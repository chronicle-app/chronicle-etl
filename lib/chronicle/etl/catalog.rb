module Chronicle
  module ETL
    # Utility methods to catalogue which Extractor, Transformer, and
    # Loader connector classes are available to chronicle-etl
    module Catalog
      PLUGINS = ['email', 'bash']

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
    end
  end
end
