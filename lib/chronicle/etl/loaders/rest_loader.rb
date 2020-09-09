require 'net/http'
require 'uri'
require 'json'

module Chronicle
  module ETL
    class RestLoader < Chronicle::ETL::Loader
      def initialize( options={} )
        super(options)
      end

      def load(result)
        uri = URI.parse("#{@options[:hostname]}#{@options[:endpoint]}")

        header = {
          "Authorization" => "Bearer #{@options[:access_token]}",
          "Content-Type": 'application/json'
        }
        use_ssl = uri.scheme == 'https'

        Net::HTTP.start(uri.host, uri.port, use_ssl: use_ssl) do |http|
          request = Net::HTTP::Post.new(uri.request_uri, header)

          # have the outer data key that json-api expects
          obj = { data: result } unless result[:data]
          request.body = obj.to_json

          http.request(request)
        end
      end
    end
  end
end
