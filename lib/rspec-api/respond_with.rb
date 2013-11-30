require 'rspec-api/respond_with/metadata'
require 'rspec-api/respond_with/valid'
require 'rspec-api/respond_with/request'

module RSpecApi
  module RespondWith
    include Metadata
    include Valid
    include Request

    def respond_with(status, values = {}, &block)
      request_params = build_request_params
      result = request status, request_params, values, &block

      other_requests(request_params).map do |extra_request|
        body = values.merge extra_request.fetch(:params, {})
        params = request_params.merge extra_request.fetch(:expect, {})
        result = [*result] << request(status, params, body, &block)
      end

      result
    end

  private

    def build_request_params
      rspec_api_params.dup.tap do |params|
        params[:route] = params[:route].dup if params[:route]
        params[:extra] = {}
      end
    end

    def other_requests(params = {})
      if valid?(params) && params[:collection]
        params.fetch :extra_requests, {}
      else
        {}
      end
    end
  end
end