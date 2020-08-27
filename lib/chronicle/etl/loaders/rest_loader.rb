require 'net/http'
require 'uri'
require 'json'

module Chronicle
  module ETL
    class RestLoader < Chronicle::ETL::Loader
      def initialize(options={})
        super(options)
      end

      def load(result)
        uri = URI.parse("#{@options[:hostname]}#{@options[:endpoint]}")

        header = {
          "Authorization" => "Bearer #{@options[:access_token]}",
          "Content-Type": 'application/json'
        }

        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Post.new(uri.request_uri, header)

        obj = {data: result} unless result[:data]
        request.body = obj.to_json

        response = http.request(request)
      end
    end
  end
end
