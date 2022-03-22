module Chronicle
  module ETL
    module Secrets
      def self.unset(namespace, key)
        config = self.get(namespace)
        config.delete(key.to_sym)
        Chronicle::ETL::Config.write_secrets(namespace, config)
      end

      def self.set(namespace, key, value)
        raise(SecretsError, "Illegal namespace") unless valid_namespace_name?(namespace)

        config = self.get(namespace)
        config[key.to_sym] = value
        Chronicle::ETL::Config.write_secrets(namespace, config)
      end

      def self.all(namespace=nil)
        namespaces = namespace.nil? ? Chronicle::ETL::Config.available_secret_namespaces : [namespace]

        namespaces.to_h do |namespace|
          [namespace.to_sym, get(namespace)]
        end
      end

      def self.get(namespace)
        Chronicle::ETL::Config.load_secrets_from_config(namespace)
      end

      def self.valid_namespace_name?(namespace)
        namespace.match(/^[a-z0-9\-]+$/)
      end
    end
  end
end
