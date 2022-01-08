require 'forwardable'

module Chronicle
  module ETL
    module Registry
      # Gives a connector class the ability to let the Chronicle::ETL::Registry
      # know about itself
      module SelfRegistering
        extend Forwardable

        attr_accessor :connector_registration

        def_delegators :@connector_registration, :description, :provider, :identifier

        # Creates a ConnectorRegistration for this connector's details and register's it
        # into the Registry
        def register_connector
          @connector_registration ||= ::Chronicle::ETL::Registry::ConnectorRegistration.new(self)
          yield @connector_registration if block_given?
          ::Chronicle::ETL::Registry.register(@connector_registration)
        end
      end
    end
  end
end
