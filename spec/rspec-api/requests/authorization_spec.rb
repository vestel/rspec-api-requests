require 'spec_helper'
require 'rspec-api/requests'

describe 'authorize_with', sandboxing: true do
  include RSpecApi::Requests

  let(:block) { Proc.new { should_authorize_with 'token' } }
  let(:action) {
    authorize_with 'token'
    get '/concerts', params, &block
  }

  context 'given an action that does not override the authorization' do
    let(:params) { {} }
    it { expect(action).to pass }
  end

  context 'given an action that overrides the authorization' do
    let(:params) { {authorize_with: 'action-specific-token'} }
    it { expect(action).not_to pass }
  end
end

