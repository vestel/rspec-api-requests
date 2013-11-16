require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/array/conversions'

require 'rspec-api/http_client'
require 'rspec-api/expectations'

module RSpecApi
  module Responses
    module RespondWith
      def respond_with(status, params = {}, &block)
        request, request_errors = build_request params
        expectations = build_expectations status

        describe_request(request) do
          if request_errors.none?
            response = send_request request
            expect_response response, expectations
            # NOTE: might move the following *inside* expect_response
            context 'matches custom expectations' do
              it { instance_exec response, request[:prefix_params], &block }
            end if block_given?
          else
            it { pending "To send a request, specify #{request_errors.to_sentence}" }
          end
        end
      end

    private

      def describe_request(request, &block)
        RSpec::Core::ExampleGroup.describe description_for(request) do
          extend RSpecApi::HttpClient
          extend RSpecApi::Expectations
          instance_eval &block
        end.register
      end

      def build_request(params)
        request = interpolate rspec_api[:route], params
        request.merge! rspec_api.slice(:host, :action, :authorize_with)
        missing_required_fields = [:host, :route, :action] - request.keys
        [request, missing_required_fields]
      end

      def build_expectations(status)
        rspec_api.slice(:collection).merge status: status
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end

      def description_for(request)
        "at #{request[:route]}".tap do |desc|
          desc << " with #{request[:body]}" if request[:body].any?
        end
      end

      def interpolate(route, params = {})
        {}.tap do |result|
          result[:prefix_params] = {}
          result[:route] = route.dup.tap do |route|
            params.keys.each do |param|
              params.delete(param).tap do |value|
                route.gsub! "/:#{param}", "/#{value}"
                result[:prefix_params][param] = value
              end if route.match "/:#{param}"
            end
          end if route
          result[:body] = params
        end
      end
    end
  end
end