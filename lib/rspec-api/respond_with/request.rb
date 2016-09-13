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

        describe description_for(request) do
          if valid
            extend RSpecApi::Requests::Valid
            valid_request request, expectations, prefix_params, &block
          else
            extend RSpecApi::Requests::Pending
            pending_request
          end
        end
      end

    private

      def request_for(params, values)
        keys = [:host, :action, :adapter, :authorize_with, :throttle]
        route, body, extra = interpolate params[:route], values, params[:extra]
        [params.slice(*keys).merge(route: route, body: body), params[:extra]]
      end

      def expectations_for(status, params)
        keys = [:collection, :attributes, :sort, :filter, :page_links, :callback]
        params.slice(*keys).delete_if{|k, v| v.nil?}.tap do |expectations|
          expectations[:status] = status
          expectations[:type] = :json
        end
      end

      def description_for(opts = {})
        "#{opts.fetch(:action, '').upcase} #{opts[:route]}".tap do |desc|
          desc << " with #{opts[:body]}" if opts.fetch(:body, {}).any?
        end
      end

      def interpolate(route, values = {}, extra = {})
        [route, values, extra].tap do |route, values, extra|
          route = route.tap do |route|
            values.keys.each do |param|
              values.delete(param).tap do |value|
                route.gsub! "=:#{param}", "=#{value}"
                route.gsub! "/:#{param}", "/#{value}"
                extra[param] = value
              end if (route.match("=:#{param}") || route.match("/:#{param}"))
            end
          end
        end
        values = values['.*'] if values.key?('.*')
        [route, values, extra]
      end
    end
  end
end