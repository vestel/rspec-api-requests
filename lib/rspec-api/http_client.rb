require 'active_support/core_ext/object/blank'
require 'faraday'
require 'faraday_middleware' # TODO: use autoload, we only need EncodeJson

module RSpecApi
  module HttpClient
    def send_request(options = {})
      conn = Faraday.new options[:host] do |c|
        c.use FaradayMiddleware::EncodeJson
        c.adapter *(options.fetch :adapter, [:net_http])
      end
      conn.headers[:user_agent] = 'RSpec API'
      conn.headers[:accept] = 'application/json'
      conn.authorization *options[:authorize_with].flatten if options[:authorize_with]
      sleep options[:throttle] if options[:throttle]
      conn.send *options.values_at(:action, :route, :body)
    rescue Faraday::Error::ConnectionFailed => e
      pending "Could not connect: #{e}"
    end
  end
end