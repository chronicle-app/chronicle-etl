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
          # TODO: this assumes provider:plugin one-to-one
          unless Chronicle::ETL::Registry::PluginRegistry.installed?(provider)
            cli_fail(message: "Plugin for #{provider} is not installed.")
          end

          begin
            Chronicle::ETL::Registry::PluginRegistry.activate(provider)
          rescue PluginError => e
            cli_fail(message: "Could not load plugin '#{provider}'.\n" + e.message, exception: e)
          end

          authorizer_klass = Authorizer.find_by_provider(provider.to_sym)
          cli_fail(message: "An authorizer for '#{provider}' could not be found.") unless authorizer_klass

          authorizer = authorizer_klass.new(port: options[:port], credentials: options[:credentials])

          secrets = authorizer.authorize!

          namespace = options[:secrets] || provider
          Chronicle::ETL::Secrets.set_all(namespace, secrets)

          pp secrets if options[:print]

          cli_exit(message: "Authorization saved to '#{namespace}' secrets")
        rescue StandardError => e
          cli_fail(message: "Authorization not successful.\n" + e.message, exception: e)
        end
      end
    end
  end
end
