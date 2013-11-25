require 'active_support/core_ext/object/blank'
require 'faraday'

module RSpecApi
  module HttpClient
    def send_request(options = {})
      action, route, body = extract_request_from options
      conn = Faraday.new options[:host] do |c|
        c.adapter *(options.fetch :adapter, [:net_http])
      end
      conn.headers[:user_agent] = 'RSpec API'
      conn.headers[:accept] = 'application/json'
      conn.authorization *options[:authorize_with].flatten if options[:authorize_with]
      sleep options[:throttle] if options[:throttle]
      conn.send action, route, body
    rescue Faraday::Error::ConnectionFailed => e
      pending "Could not connect: #{e}"
    end

  private

    def extract_request_from(options = {})
      action, route, raw_body = options.values_at :action, :route, :body
      body = submit?(action) ? raw_body.to_json : raw_body if raw_body.present?
      [action, route, body]
    end

    def submit?(action)
      [:put, :patch, :post, :delete].include? action
    end
  end
end