require 'rspec/core'
require 'rspec-api/respond_with'

module RSpecApi
  # Provides the `respond_with` method to RSpec Example groups, useful to
  # make requests to web APIs and verify their expectations:
  #
  # To have these matchers available inside of an RSpec `describe` block,
  # include that block inside a block with the `:rspec_api` metadata, or
  # explicitly include the RSpecApi::Requests module.
  #
  # @example Tag a `describe` block as `:rspec_api`:
  #   describe "Artists", rspec_api: true do
  #     describe 'GET /artists', rspec_api_requests: {...}
  #       ... # here you can write `respond_with :ok`
  #     end
  #   end
  #
  # @example Explicitly include the RSpecApi::Responses module
  #   describe "Artists" do
  #     include RSpecApi::Requests
  #     describe 'GET /artists', rspec_api_requests: {...}
  #       ... # here you can write `respond_with :ok`
  #     end
  #   end
  module Requests
    include RespondWith
  end
end

RSpec.configuration.extend RSpecApi::Requests, rspec_api: true