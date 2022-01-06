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
      alias id name

      def initialize(job_definition)
        @job_definition = job_definition
        @name = @job_definition.definition[:name]
        @extractor_options = @job_definition.extractor_options
        @transformer_options = @job_definition.transformer_options
        @loader_options = @job_definition.loader_options

        set_continuation if use_continuation?
        yield self if block_given?
      end

      def instantiate_extractor
        @extractor_klass = @job_definition.extractor_klass
        @extractor_klass.new(@extractor_options)
      end

      def instantiate_transformer(extraction)
        @transformer_klass = @job_definition.transformer_klass
        @transformer_klass.new(@transformer_options, extraction)
      end

      def instantiate_loader
        @loader_klass = @job_definition.loader_klass
        @loader_klass.new(@loader_options)
      end

      def save_log?
        # TODO: this needs more nuance
        return !id.nil?
      end

      def to_s
        output = "Job"
        output += " '#{name}'".bold if name
        output += "\n"
        output += "  → Extracting from #{@job_definition.extractor_klass.description}\n"
        output += "  → Transforming #{@job_definition.transformer_klass.description}\n"
        output += "  → Loading to #{@job_definition.loader_klass.description}\n"
      end

      private

      def set_continuation
        continuation = Chronicle::ETL::JobLogger.load_latest(@id)
        @extractor_options[:continuation] = continuation
      end

      def use_continuation?
        @job_definition.incremental?
      end
    end
  end
end
