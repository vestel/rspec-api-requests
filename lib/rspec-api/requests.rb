require 'rspec/core'
require 'rspec-api/requests/actions'
# require 'rspec-api/requests/attributes'
# require 'rspec-api/requests/remote'

module RSpecApi
  module Requests
    include Actions
    # include Attributes
    # include Remote
  end
end

# RSpecApi::Requests provides the actions method to test RESTful APIs.
#
# To have this method available inside of an RSpec `describe` block, tag that
# block with the `:rspec_api` metadata:
#
#  describe "Artists", rspec_api: true do
#     ... # here you can write `expect_response response, status: :ok, etc.
#  end
RSpec.configuration.extend RSpecApi::Requests, rspec_api: true

# You can also explicitly extend the example group with RSpecApi::Requests:
#
#  describe "Artists" do
#     extend RSpecApi::Requests
#     ... # here you can write `expect_response response, status: :ok, etc.
#  end
#