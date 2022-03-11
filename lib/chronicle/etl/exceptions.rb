module Chronicle
  module ETL
    class Error < StandardError; end

    class ConfigurationError < Error; end

    class RunnerTypeError < Error; end

    class JobDefinitionError < Error
      attr_reader :job_definition

      def initialize(job_definition)
        @job_definition = job_definition
        super
      end
    end

    class PluginError < Error
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end

    class PluginNotAvailableError < PluginError; end
    class PluginLoadError < PluginError; end

    class ConnectorNotAvailableError < Error
      def initialize(message, provider: nil, name: nil)
        super(message)
        @provider = provider
        @name = name
      end
      attr_reader :name, :provider
    end

    class ProviderNotAvailableError < ConnectorNotAvailableError; end
    class ProviderConnectorNotAvailableError < ConnectorNotAvailableError; end

    class ExtractionError < Error; end

    class SerializationError < Error; end

    class TransformationError < Error
      attr_reader :transformation

      def initialize(message=nil, transformation:)
        super(message)
        @transformation = transformation
      end
    end

    class UntransformableRecordError < TransformationError; end
  end
end
