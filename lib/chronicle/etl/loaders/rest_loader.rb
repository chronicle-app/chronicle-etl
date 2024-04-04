# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'chronicle/serialization'

module Chronicle
  module ETL
    class RestLoader < Chronicle::ETL::Loader
      register_connector do |r|
        r.identifier = :rest
        r.description = 'a REST endpoint'
      end

      setting :hostname, required: true
      setting :endpoint, required: true
      setting :access_token

      def load(payload)
        uri = URI.parse("#{@config.hostname}#{@config.endpoint}")

        header = {
          'Authorization' => "Bearer #{@config.access_token}",
          'Content-Type': 'application/json'
        }
        use_ssl = uri.scheme == 'https'

        Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
          request = Net::HTTP::Post.new(uri.request_uri, header)
          request.body = payload.to_json
          http.request(request)
        end
      end
    end
  end
end
