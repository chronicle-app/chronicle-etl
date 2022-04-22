require "active_support/core_ext/hash/keys"

module Chronicle
  module ETL
    # Secret management module
    module Secrets
      module_function

      # Whether a given namespace exists
      def exists?(namespace)
        Chronicle::ETL::Config.exists?("secrets", namespace)
      end

      # Save a setting to a namespaced config file
      def set(namespace, key, value)
        config = read(namespace)
        config[key.to_sym] = value
        write(namespace, config)
      end

      # Save a hash to a secrets namespace
      def set_all(namespace, secrets)
        config = read(namespace)
        config = config.merge(secrets.deep_stringify_keys)
        write(namespace, config)
      end

      # Remove a setting from a namespaced config file
      def unset(namespace, key)
        config = read(namespace)
        config.delete(key.to_sym)
        write(namespace, config)
      end

      # Retrieve all secrets from all namespaces
      def all(namespace = nil)
        namespaces = namespace.nil? ? available_secrets : [namespace]
        namespaces
          .to_h { |namespace| [namespace.to_sym, read(namespace)] }
          .delete_if { |_, v| v.empty? }
      end

      # Return whether a namespace name is valid (lowercase alphanumeric and -)
      def valid_namespace_name?(namespace)
        namespace.match(/^[a-z0-9\-]+$/)
      end

      # Read secrets from a config file
      def read(namespace)
        definition = Chronicle::ETL::Config.load("secrets", namespace)
        definition[:secrets] || {}
      end

      # Write secrets to a config file
      def write(namespace, secrets)
        data = {
          secrets: (secrets || {}).transform_keys(&:to_s),
          chronicle_etl_version: Chronicle::ETL::VERSION
        }.deep_stringify_keys
        Chronicle::ETL::Config.write("secrets", namespace, data)
      end

      # Which config files are available in ~/.config/chronicle/etl/secrets
      def available_secrets
        Chronicle::ETL::Config.available_configs('secrets')
      end
    end
  end
end
