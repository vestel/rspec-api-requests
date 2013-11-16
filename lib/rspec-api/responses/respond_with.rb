require 'active_support/core_ext/hash/slice'
require 'active_support/core_ext/array/conversions'

require 'rspec-api/http_client'
require 'rspec-api/expectations'

module RSpecApi
  module Responses
    module RespondWith
      def respond_with(status, params = {}, &block)
        request, request_errors, prefix_params = build_request params
        expectations = build_expectations status

        describe_request(request) do
          if request_errors.none?
            response = send_request request
            expect_response response, expectations, prefix_params, &block
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
        request, prefix_params = interpolate rspec_api[:route], params
        request.merge! rspec_api.slice(:host, :action, :authorize_with)
        missing_required_fields = [:host, :route, :action] - request.keys
        [request, missing_required_fields, prefix_params]
      end

      def build_expectations(status)
        keys = [:collection, :attributes]
        rspec_api.slice(*keys).delete_if{|k, v| v.blank?}.tap do |expectations|
          expectations[:status] = status
        end
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
        [{body: params}, {}].tap do |result, prefix_params|
          result[:route] = route.dup.tap do |route|
            result[:body].keys.each do |param|
              result[:body].delete(param).tap do |value|
                route.gsub! "/:#{param}", "/#{value}"
                prefix_params[param] = value
              end if route.match "/:#{param}"
            end
          end if route
        end
      end
    end
  end
end