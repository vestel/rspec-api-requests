require 'rspec-api/respond_with/valid'
require 'rspec-api/requests/valid'
require 'rspec-api/requests/pending'

module RSpecApi
  module RespondWith
    module Request
      include Valid

      def request(status, params = {}, values = {}, &block)
        valid = valid? params
        expectations = expectations_for status, params
        request, prefix_params = request_for params, values

        RSpec::Core::ExampleGroup.describe description_for(request) do
          if valid
            extend RSpecApi::Requests::Valid
            valid_request request, expectations, prefix_params, &block
          else
            extend RSpecApi::Requests::Pending
            pending_request
          end
        end.register
      end

    private

      def request_for(params, values)
        keys = [:host, :action, :adapter, :authorize_with, :throttle]
        route, body, extra = interpolate params[:route], values
        [params.slice(*keys).merge(route: route, body: body), extra]
      end

      def expectations_for(status, params)
        keys = [:collection, :attributes, :sort, :filter, :page_links, :callback]
        params.slice(*keys).delete_if{|k, v| v.blank?}.tap do |expectations|
          expectations[:status] = status
        end
      end

      def description_for(opts = {})
        "#{opts.fetch(:action, '').upcase} #{opts[:route]}".tap do |desc|
          desc << " with #{opts[:body]}" if opts.fetch(:body, {}).any?
        end
      end

      def interpolate(route, values = {})
        [(route.dup if route), values, {}].tap do |route, body, extra|
          route = route.tap do |route|
            body.keys.each do |param|
              body.delete(param).tap do |value|
                route.gsub! "/:#{param}", "/#{value}"
                extra[param] = value
              end if route.match "/:#{param}"
            end
          end
        end
      end
    end
  end
end