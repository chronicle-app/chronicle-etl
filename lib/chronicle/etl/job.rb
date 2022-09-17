require 'forwardable'

module Chronicle
  module ETL
    # A runner job
    #
    # TODO: this can probably be merged with JobDefinition. Not clear
    # where the boundaries are
    class Job
      extend Forwardable

      def_delegators :@job_definition, :dry_run?

      attr_accessor :name,
                    :extractor_klass,
                    :extractor_options,
                    :transformer_klass,
                    :transformer_options,
                    :loader_klass,
                    :loader_options,
                    :job_definition

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
        @transformer_klass.new(extraction, @transformer_options)
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
        output = "Job summary\n".upcase.bold
        # output = ""
        output += "#{name}:\n" if name
        output += "→ #{'Extracting'} from #{@job_definition.extractor_klass.description}\n"
        output += options_to_s(@extractor_options)
        output += "→ #{'Transforming'} #{@job_definition.transformer_klass.description}\n"
        output += options_to_s(@transformer_options)
        output += "→ #{'Loading'} to #{@job_definition.loader_klass.description}\n"
        output += options_to_s(@loader_options)
        output
      end

      private

      def options_to_s(options, indent: 4)
        output = ""
        options.each do |k, v|
          output += "#{' ' * indent}#{k.to_s.light_blue}: #{v}\n"
        end
        output
      end

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
