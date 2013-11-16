module RSpecApi
  module Requests
    module Authorization
      def authorize_with(params = {})
        rspec_api[:authorize_with] = params
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end