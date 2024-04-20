module Chronicle
  module Foo
    class SimpleAuthorizer < Chronicle::ETL::Authorizer
      provider :foo

      def authorize!
        { token: 'abc' }
      end
    end
  end
end
