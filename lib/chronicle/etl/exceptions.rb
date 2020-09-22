module Chronicle
  module ETL
    class Error < StandardError; end;

    class InvalidTransformedRecordError < Error; end

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
  end
end
