require 'spec_helper'
require 'rspec-api/requests'

describe 'Basic', rspec_api: true do
  get '/notifications', host: 'https://api.github.com', authorize_with: {token: ENV['RSPEC_API_GITHUB_TOKEN']} do
    respond_with :ok
  end
end

describe 'Host', rspec_api: true do
  host 'https://api.github.com'

  get '/notifications', authorize_with: {token: ENV['RSPEC_API_GITHUB_TOKEN']} do
    respond_with :ok
  end

  get '/notifications', host: 'http://example.com', authorize_with: {token: ENV['RSPEC_API_GITHUB_TOKEN']} do
    respond_with :not_found
  end
end

describe 'Authorization', rspec_api: true do
  host 'https://api.github.com'
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  get '/notifications' do
    respond_with :ok
  end

  get '/notifications', authorize_with: {token: 'wrong-token'} do
    respond_with :unauthorized
  end
end

describe 'Custom expectations', rspec_api: true do
  host 'https://api.github.com'
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  get '/notifications' do
    respond_with :ok do |response|
      expect(response.status).to be 200
    end

    respond_with :ok do |response|
      expect(response.status).not_to be 404
    end
  end
end

describe 'Routes with placeholders', rspec_api: true do
  host 'https://api.github.com'
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  get '/notifications/threads/:id' do
    respond_with :ok, id: 17915960
    respond_with :not_found, id: -1
  end
end

describe 'Query params', rspec_api: true do
  host 'https://api.github.com'
  authorize_with token: ENV['RSPEC_API_GITHUB_TOKEN']

  get '/notifications' do
    respond_with :ok, since: '2201-01-01T00:00:00Z' do |response|
      expect(response.body).to eq '[]'
    end
  end

  get '/notifications?since=2201-01-01T00:00:00Z' do
    respond_with :ok do |response|
      expect(response.body).to eq '[]'
    end
  end
end
