require 'pry'

module Chronicle
  module ETL
    class Job
      attr_accessor :name,
                    :extractor_klass,
                    :extractor_options,
                    :transformer_klass,
                    :transformer_options,
                    :loader_klass,
                    :loader_options

      # TODO: build a proper id system
      alias :id :name

      def initialize(definition)
        validate_definition(definition)
        @name = definition[:name]
        @extractor_klass = load_klass(:extractor, definition[:extractor][:name])
        @extractor_options = definition[:extractor][:options] || {}

        @transformer_klass = load_klass(:transformer, definition[:transformer][:name])
        @transformer_options = definition[:transformer][:options] || {}

        @loader_klass = load_klass(:loader, definition[:loader][:name])
        @loader_options = definition[:loader][:options] || {}

        set_continuation
        yield self if block_given?
      end

      def validate_definition definition
      end

      def instantiate_extractor
        instantiate_klass(:extractor)
      end

      def instantiate_transformer data
        instantiate_klass(:transformer, data)
      end

      def instantiate_loader
        instantiate_klass(:loader)
      end

      private

      def instantiate_klass(phase, *args)
        options = self.send("#{phase.to_s}_options")
        args = args.unshift(options)
        klass = self.send("#{phase.to_s}_klass")
        klass.new(*args)
      end

      def load_klass phase, identifier
        Chronicle::ETL::Catalog.phase_and_identifier_to_klass(phase, identifier)
      end

      def set_continuation
        continuation = Chronicle::ETL::JobLogger.load_latest(@job_id)
        @extractor_options[:continuation] = continuation
      end
    end
  end
end
