module Chronicle
  module ETL
    # Secret management module
    module Secrets
      # Save a setting to a namespaced config file
      def self.set(namespace, key, value)
        config = read(namespace)
        config[key.to_sym] = value
        write(namespace, config)
      end

      # Remove a setting from a namespaced config file
      def self.unset(namespace, key)
        config = read(namespace)
        config.delete(key.to_sym)
        write(namespace, config)
      end

      # Retrieve all secrets from all namespaces
      def self.all(namespace = nil)
        namespaces = namespace.nil? ? available_configs : [namespace]
        namespaces
          .to_h { |namespace| [namespace.to_sym, read(namespace)] }
          .delete_if { |_, v| v.empty? }
      end

      # Return whether a namespace name is valid (lowercase alphanumeric and -)
      def self.valid_namespace_name?(namespace)
        namespace.match(/^[a-z0-9\-]+$/)
      end

      # Read secrets from a config file
      def self.read(namespace)
        definition = Chronicle::ETL::Config.load("secrets", namespace)
        definition[:secrets] || {}
      end

      # Write secrets to a config file
      def self.write(namespace, secrets)
        data = {
          provider: namespace,
          secrets: (secrets || {}).transform_keys(&:to_s),
          chronicle_etl_version: Chronicle::ETL::VERSION
        }.transform_keys(&:to_s) # Should I implement deeply_transform_keys ?
        Chronicle::ETL::Config.write("secrets", namespace, data)
      end

      # Which config files are available in ~/.config/chronicle/etl/secrets
      def self.available_configs
        Chronicle::ETL::Config.available_configs('secrets')
      end
    end
  end
end
