# frozen_string_literal: true

require 'sinatra'
require 'launchy'
require 'pp'

module Chronicle
  module ETL
    module CLI
      # CLI commands for authorizing chronicle-etl with third-party services
      class Authorizations < SubcommandBase
        default_task 'new'
        namespace :authorizations

        desc "authorize", "Authorize with a third-party provider"
        option :port, desc: 'Port to run authorization server on', type: :numeric, default: 4567
        option :credentials, desc: 'Secrets namespace for where to read credentials from (default: PROVIDER)', type: :string, banner: 'NAMESPACE'
        option :secrets, desc: 'Secrets namespace for where authorization should be saved to (default: PROVIDER)', type: :string, banner: 'NAMESPACE'
        option :print, desc: 'Show authorization results (instead of just saving secrets)', type: :boolean, default: false
        def new(provider)
          authorizer_klass = find_authorizer_klass(provider)
          credentials = load_credentials(provider: provider, credentials_source: options[:credentials])
          authorizer = authorizer_klass.new(port: options[:port], credentials: credentials)

          secrets = authorizer.authorize!
          secrets_namespace = options[:secrets] || provider
          Chronicle::ETL::Secrets.set_all(secrets_namespace, secrets)

          pp secrets if options[:print]

          cli_exit(message: "Authorization saved to '#{secrets_namespace}' secrets")
        rescue StandardError => e
          cli_fail(message: "Authorization not successful.\n" + e.message, exception: e)
        end

        private

        def find_authorizer_klass(provider)
          # TODO: this assumes provider:plugin one-to-one
          unless Chronicle::ETL::Registry::PluginRegistry.installed?(provider)
            cli_fail(message: "Plugin for #{provider} is not installed.")
          end

          begin
            Chronicle::ETL::Registry::PluginRegistry.activate(provider)
          rescue PluginError => e
            cli_fail(message: "Could not load plugin '#{provider}'.\n" + e.message, exception: e)
          end

          Authorizer.find_by_provider(provider.to_sym) || cli_fail(message: "No authorizer available for '#{provider}'")
        end

        def load_credentials(provider:, credentials_source: nil)
          if credentials_source && !Chronicle::ETL::Secrets.exists?(credentials_source)
            cli_fail(message: "OAuth credentials specified as '#{credentials_source}' but a secrets namespace with that name does not exist.")
          end

          Chronicle::ETL::Secrets.read(credentials_source || provider)
        end
      end
    end
  end
end
