module RSpecApi
  module Requests
    module Host
      def host(host)
        rspec_api[:host] = host
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end