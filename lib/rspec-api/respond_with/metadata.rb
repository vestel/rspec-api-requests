module RSpecApi
  module RespondWith
    module Metadata
      def rspec_api_params
        metadata.fetch :rspec_api_params, {}
      end
    end
  end
end