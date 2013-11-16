require 'spec_helper'
require 'rspec-api/requests'

describe 'host', sandboxing: true do
  include RSpecApi::Requests

  let(:block) { Proc.new { should_have_host 'http://example.com' } }
  let(:action) {
    host 'http://example.com'
    get '/concerts', params, &block
  }

  context 'given an action that does not override the host' do
    let(:params) { {} }
    it { expect(action).to pass }
  end

  context 'given an action that overrides the host' do
    let(:params) { {host: 'http://example.org'} }
    it { expect(action).not_to pass }
  end
end

