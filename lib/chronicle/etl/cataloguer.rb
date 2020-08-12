module Chronicle
  module Etl
    module Cataloguer
      def self.available_classes
        parent_klasses = [Chronicle::Etl::Extractor, Chronicle::Etl::Transformer, Chronicle::Etl::Loader]
        plugins = ['email', 'bash']
        klasses = []
  
        plugins.each do |plugin|
          require "chronicle/#{plugin}"
        rescue LoadError
        end
  
        parent_klasses.each do |parent|
          klasses += ObjectSpace.each_object(Class).select { |klass| klass < parent }
        end
  
        klasses.map do |klass|
          {
            name: klass.name,
            phase: klass::ETL_PHASE.to_s,
            # provider: klass.provider
            # provider: ___  # FIXME: make this work
          }
        end
      end

      def self.provider
        self.class
      end

      def self.build_in?
        true
      end
    end
  end
end
