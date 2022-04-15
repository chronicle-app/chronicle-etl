module Chronicle
  module ETL
    # An authorization strategy for a third-party data source
    class Authorizer
      class << self
        attr_reader :provider_name

        # Macro for setting provider on an Authorizer
        def provider(provider_name)
          @provider_name = provider_name
        end

        # From all loaded Authorizers, return the first one that matches
        # a given provider
        #
        # @todo Have a proper identifier system for authorizers
        #   (to have more than one per plugin)
        def find_by_provider(provider)
          ObjectSpace.each_object(::Class).select {|klass| klass < self }.find do |authorizer|
            authorizer.provider_name == provider
          end
        end
      end

      # Construct a new authorizer
      def initialize(args)
      end

      # Main entry-point for authorization flows. Implemented by subclass
      def authorize!
        raise NotImplementedError
      end
    end
  end
end

require_relative 'oauth_authorizer'
