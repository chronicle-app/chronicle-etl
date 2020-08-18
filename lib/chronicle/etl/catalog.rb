module Chronicle
  module Etl
    # Utility methods to catalogue which Extractor, Transformer, and
    # Loader classes are available to chronicle-etl
    module Catalog
      def self.available_classes
        parent_klasses = [
          Chronicle::Etl::Extractor,
          Chronicle::Etl::Transformer,
          Chronicle::Etl::Loader
        ]

        # TODO: have a registry of plugins
        plugins = ['email', 'bash']

        # Attempt to load each chronicle plugin that we might know about so
        # that we can later search for subclasses to build our list of
        # available classes
        plugins.each do |plugin|
          require "chronicle/#{plugin}"
        rescue LoadError
          # this will happen if the gem isn't available globally 
        end

        klasses = []
        parent_klasses.each do |parent|
          klasses += ObjectSpace.each_object(Class).select { |klass| klass < parent }
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

      def phase
        ancestors = self.ancestors
        return :extractor if ancestors.include? Chronicle::Etl::Extractor
        return :transformer if ancestors.include? Chronicle::Etl::Transformer
        return :loader if ancestors.include? Chronicle::Etl::Loader
      end

      def provider
        # TODO: needs better convention for a gem reporting its provider name
        provider = to_s.split('::')[1].downcase
        provider == 'etl' ? 'chronicle' : provider
      end

      def built_in?
        to_s.include? 'Chronicle::Etl'
      end
    end
  end
end
