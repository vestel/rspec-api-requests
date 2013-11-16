require 'spec_helper'
require 'rspec-api/requests'

# An integration test that uses `get` against a live API to make sure the
# result is as expected. This test is not included in the default `rspec`
# because it might fail due to third-party API issues, but is useful to see
# how `get` and `respond_with` work in the real world.
#
# In order to run this test, obtain a GitHub API key and store it in the
# environment variable RSPEC_API_GITHUB_TOKEN
#
describe 'List all public repositories', rspec_api: true do
  host 'https://api.github.com/'
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']
  #
  # has_attribute :id, {type: :number}
  # has_attribute :name, {type: :string}, url: {type: {string: :url}}}

  get '/repositories' do
    respond_with :ok
  end

  get '/repositories?since=1234' do
    # respond_with :ok
  end

  get '/repos/:owner/:repo' do
    # respond_with :ok, owner: 'rspec-api', repo: 'rspec-api-requests'
  end

  get '/repos/:owner/:repo' do
    # respond_with :not_found, owner: 'not-an-owner', repo: 'not-a-repo'
  end
end