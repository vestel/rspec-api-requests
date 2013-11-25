require 'rspec-api/respond_with/metadata'
require 'rspec-api/respond_with/valid'
require 'rspec-api/respond_with/request'

module RSpecApi
  module RespondWith
    include Metadata
    include Valid
    include Request

    def respond_with(status, values = {}, &block)
      result = request status, rspec_api_params, values, &block

      extra_requests.map do |extra_request|
        values = values.merge extra_request.fetch(:params, {})
        params = rspec_api_params.merge extra_request.fetch(:expect, {})
        result = [*result] << request(status, params, values, &block)
      end

      result
    end

    def extra_requests
      if valid?(rspec_api_params) && rspec_api_params[:collection]
        rspec_api_params.fetch :extra_requests, {}
      else
        {}
      end
    end
  end
end