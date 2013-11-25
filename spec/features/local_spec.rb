require 'spec_helper'
require 'rspec-api/requests'
require 'rack/test'

app = -> env {[200, {"Content-Type" => "application/json; charset=utf-8"}, ["[]"]] }

describe 'Examples from a Rack app', rspec_api: true do

  concerts_params = {
    adapter: [:rack, app],
    action: 'get',
    route: '/',
    collection: true
  }

  describe 'Concerts', rspec_api_params: concerts_params do
    respond_with :ok
  end
end