require 'faraday'
require 'logger'

module RSpecApi
  module HttpClient
    def send_request(options = {})
      logger = Logger.new 'faraday.log'
      conn = Faraday.new options[:host] do |c|
        c.use Faraday::Adapter::NetHttp
        c.use Faraday::Response::Logger, logger
      end

      conn.headers[:user_agent] = 'RSpec API'
      conn.authorization *options[:authorize_with].flatten if options[:authorize_with]

      # sleep 0.5 # TODO: Pass as a parameter
      conn.send *options.values_at(:action, :route, :body)
    rescue Faraday::Error::ConnectionFailed => e
      pending "Could not connect: #{e}"
    end
  end
end