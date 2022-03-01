module Chronicle
  module ETL
    class Error < StandardError; end

    class ConfigurationError < Error; end

    class RunnerTypeError < Error; end

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
