require 'spec_helper'
require 'rspec-api/requests'

describe 'has_attribute', sandboxing: true do
  include RSpecApi::Requests
  let(:params) { {} }

  context 'by default' do
    let(:block) { Proc.new { should_have_attributes id: {type: :number} } }
    let(:action) {
      has_attribute :id, type: :number
      get '/concerts', params, &block
    }

    context 'given an action that does not override the attributes' do
      it { expect(action).to pass }
    end

    context 'given an action that overrides the attributes' do
      let(:params) { {attributes: {}} }
      it { expect(action).not_to pass }
    end
  end

  context 'with nested attributes' do
    let(:block) { Proc.new { should_have_attributes login: {type: {object: {id: {type: :number}}}} } }
    let(:action) {
      has_attribute :login, type: :object do
        has_attribute :id, type: :number
      end
      get '/concerts', params, &block
    }
    it { expect(action).to pass }
  end
end