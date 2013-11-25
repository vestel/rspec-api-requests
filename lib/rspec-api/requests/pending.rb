module RSpecApi
  module Requests
    module Pending
      def pending_request
        it {
          pending <<-EOF
            To use respond_with, specify the parameters for the request and
            the expectations in the :rspec_api_params example metadata,
            indicating the action, the route, and either host or adapter.
          EOF
        }
      end
    end
  end
end