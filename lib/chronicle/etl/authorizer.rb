module Chronicle
  module ETL
    class Authorizer
      class << self
        attr_reader :provider_name

        def provider(provider_name)
          @provider_name = provider_name
        end

        def find_by_provider(provider)
          ObjectSpace.each_object(::Class).select {|klass| klass < self }.find do |authorizer|
            authorizer.provider_name == provider
          end
        end
      end

      def initialize(args)
      end

      def authorize!
        raise NotImplementedError
      end

      def load_credentials
        Chronicle::ETL::Secrets.read(self.class.provider_name)
      end
    end
  end
end

require_relative 'oauth_authorizer'
