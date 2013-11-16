require 'spec_helper'
require 'rspec-api/responses'

describe 'send_request' do
  include RSpecApi::HttpClient
  let(:params) { {host: host, route: '/', action: :get} }

  context 'given a valid request' do
    let(:host) { 'http://example.com' }
    it 'returns an object that responds to status, headers and body' do
      response = send_request params
      expect(response.status).to be_an Integer
      expect(response.headers).to be_a Hash
      expect(response.body).to be_a String
    end
  end

  context 'given a failing request' do
    let(:host) { 'https://example.com' }
    it { expect(send_request params).to be_pending }
  end
end