require 'spec_helper'
require 'rspec-api/requests'

# An integration test against a live API to make sure the result is as expected.
# This test is not included in the default `rspec` because it might fail due
# to third-party API issues, but is useful to see rspec-api in the real world.
#
# In order to run this test, obtain a GitHub API key and store it in the
# environment variable RSPEC_API_GITHUB_TOKEN
#
describe 'Examples from GitHub API', rspec_api: true do

  gists_params = {
    host: 'https://api.github.com',
    action: 'get',
    authorize_with: {token: ENV['RSPEC_API_GITHUB_TOKEN']},
    route: '/gists',
    collection: true,
    attributes: {url: {type: {string: :url}}},
    extra_requests: [{
      expect: {filter: {by: :updated_at, compare_with: :>=, value: '2012-10-10T00:00:00Z'}},
      params: {since: '2012-10-10T00:00:00Z'}
    }]
  }

  describe 'GitHub Gists', rspec_api_params: gists_params do
    respond_with :ok
  end

  thread_params = {
    host: 'https://api.github.com',
    action: 'get',
    authorize_with: {token: ENV['RSPEC_API_GITHUB_TOKEN']},
    route: '/notifications/threads/:id',
    collection: false,
    attributes: {url: {type: {string: :url}}}
  }

  describe 'GitHub Notification Thread', rspec_api_params: thread_params do
    respond_with :ok, id: 17915960 do |response, prefix_params|
      expect(prefix_params).to eq id: 17915960
    end
  end
end