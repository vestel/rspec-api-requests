module RSpecApi
  module Requests
    module HasAttribute
      def has_attribute(name, options)
        (rspec_api[:attributes] ||= {})[name] = options
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end