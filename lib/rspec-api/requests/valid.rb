require 'rspec-api/http_client'
require 'rspec-api/expectations'

module RSpecApi
  module Requests
    module Valid
      include RSpecApi::HttpClient
      include RSpecApi::Expectations

      def valid_request(request = {}, expectations = {}, prefix_params = {}, &block)
        response = send_request request
        expect_response response, expectations, prefix_params, &block
      end
    end
  end
end