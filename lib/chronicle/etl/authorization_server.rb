require 'sinatra'
require 'omniauth'

module Chronicle
  module ETL
    class AuthorizationServer < Sinatra::Base
      class << self
        attr_accessor :latest_authorization

        def initialize(*args)
          @saved_authorization = false
          super
        end
      end

      configure do
        set :inline_templates, true
        set :dump_errors, false
        set :raise_errors, true
        disable :logging
        set :sessions, true
        set :quiet, true
        set :threaded, true
        set :environment, ENV['APP_ENV'] == 'test' ? :test : :production
      end

      puts self.environment

      use OmniAuth::Builder do
        Chronicle::ETL::OauthAuthorizer.all_omniauth_strategies.each do |klass|
          args = [klass.client_id, klass.client_secret, klass.options].compact
          provider(
            klass.strategy,
            *args
          )
        end
      end


      OmniAuth.config.logger = Chronicle::ETL::Logger
      OmniAuth.config.silence_get_warning = true
      OmniAuth.config.allowed_request_methods = %i[get]

      get '/auth/:provider/callback' do
        authorization = request.env['omniauth.auth'].to_h.deep_transform_keys(&:to_sym)
        self.class.latest_authorization = authorization
        erb "<h1>Settings saved for #{params[:provider]}</h1><p>You can now close this tab and return to your terminal!</p>"
      end

      get '/auth/failure' do
        erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
      end
    end
  end
end
