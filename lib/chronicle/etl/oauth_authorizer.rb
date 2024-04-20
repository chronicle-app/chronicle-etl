require 'omniauth'
require 'tty-spinner'

module Chronicle
  module ETL
    # An authorization strategy that uses oauth2 (and omniauth under the hood)
    class OauthAuthorizer < Authorizer
      class << self
        attr_reader :strategy, :provider_name, :authorization_to_secret_map
        attr_accessor :client_id, :client_secret

        # Macro for specifying which omniauth strategy to use
        def omniauth_strategy(strategy)
          @strategy = strategy
        end

        # Macro for specifying which omniauth scopes to request
        def scope(value)
          options[:scope] = value
        end

        # Macro for specifying hash of returned authorization to secrets hash
        def pluck_secrets(map)
          @authorization_to_secret_map = map
        end

        # # Macro for specifying options to pass to omniauth
        def options
          @options ||= {}
        end

        # Returns all subclasses of OauthAuthorizer
        # (Used by AuthorizationServer to build omniauth providers)
        def all
          ObjectSpace.each_object(::Class).select { |klass| klass < self }
        end
      end

      attr_reader :authorization

      # Create a new instance of OauthAuthorizer
      def initialize(port:, credentials: {})
        @port = port
        @credentials = credentials
        super
      end

      # Start up an authorization server and handle the oauth flow
      def authorize!
        associate_oauth_credentials
        @server = load_server
        spinner = TTY::Spinner.new(':spinner :title', format: :dots_2)
        spinner.auto_spin
        spinner.update(title: "Starting temporary authorization server on port #{@port}"'')

        server_thread = start_authorization_server(port: @port)
        start_oauth_flow

        spinner.update(title: 'Waiting for authorization to complete in your browser')
        sleep 0.1 while authorization_pending?(server_thread)

        @server.quit!
        server_thread.join
        spinner.success("(#{'successful'.green})")

        # TODO: properly handle failed authorizations
        raise Chronicle::ETL::AuthorizationError unless @server.latest_authorization

        @authorization = @server.latest_authorization

        extract_secrets(authorization: @authorization, pluck_values: self.class.authorization_to_secret_map)
      end

      private

      def authorization_pending?(server_thread)
        server_thread.status && !@server.latest_authorization
      end

      def associate_oauth_credentials
        self.class.client_id = @credentials[:client_id]
        self.class.client_secret = @credentials[:client_secret]
      end

      def load_server
        # Load at runtime so that we can set omniauth strategies based on
        # which chronicle plugin has been loaded.
        require_relative 'authorization_server'
        Chronicle::ETL::AuthorizationServer
      end

      def start_authorization_server(port:)
        @server.settings.port = port
        suppress_webrick_logging(@server)
        Thread.abort_on_exception = true
        Thread.report_on_exception = false

        Thread.new do
          @server.run!({ port: @port }) do |s|
            s.silent = true if s.class.to_s == 'Thin::Server'
          end
        end
      end

      def start_oauth_flow
        url = "http://localhost:#{@port}/auth/#{omniauth_strategy}"
        Launchy.open(url)
      rescue Launchy::CommandNotFoundError
        Chronicle::ETL::Logger.info("Please open #{url} in a browser to continue")
      end

      def suppress_webrick_logging(server)
        require 'webrick'
        server.set(
          :server_settings,
          {
            AccessLog: [],
            # TODO: make this windows friendly
            # https://github.com/winton/stasis/commit/77da36f43285fda129300e382f18dfaff48571b0
            Logger: WEBrick::Log.new('/dev/null')
          }
        )
      rescue LoadError
        # no worries if we're not using WEBrick
      end

      def extract_secrets(authorization:, pluck_values:)
        return authorization unless pluck_values&.any?

        pluck_values.each_with_object({}) do |(key, identifiers), secrets|
          secrets[key] = authorization.dig(*identifiers)
        end
      end

      def omniauth_strategy
        self.class.strategy
      end
    end
  end
end
