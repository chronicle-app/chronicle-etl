module Chronicle
  module ETL
    class Error < StandardError; end;

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

    class TransformationError < Error
      def initialize(message, record: nil)
        super(message)
        @record = record
      end
      attr_reader :record
    end

    class UntransformableRecordError < TransformationError; end
  end
end
