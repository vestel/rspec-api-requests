require 'spec_helper'
require 'rspec-api/requests'

describe 'has_attribute', sandboxing: true do
  include RSpecApi::Requests

  let(:block) { Proc.new { should_have_attributes id: {type: :number} } }
  let(:action) {
    has_attribute :id, type: :number
    get '/concerts', params, &block
  }

  context 'given an action that does not override the attributes' do
    let(:params) { {} }
    it { expect(action).to pass }
  end

  context 'given an action that overrides the attributes' do
    let(:params) { {attributes: {}} }
    it { expect(action).not_to pass }
  end
end