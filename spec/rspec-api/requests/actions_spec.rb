require 'spec_helper'
require 'rspec-api/requests'

describe 'get' do # For brevity, since :put, :patch, :delete, :post are similar
  include RSpecApi::Requests
  let(:action) { get '/concerts' }

  it 'generates a description from the action and the route' do
    expect(action.description).to eq 'GET /concerts'
  end

  it 'stores the action in the metadata' do
    expect(action.metadata[:action]).to eq :get
  end

  it 'stores the route in the metadata' do
    expect(action.metadata[:route]).to eq '/concerts'
  end

  context 'given a passing block', sandboxing: true do
    let(:action) { get('/concerts') { it { expect(true).to be_true } } }
    it { expect(action).to pass }
  end

  context 'given a failing block', sandboxing: true do
    let(:action) { get('/concerts') { it { expect(true).to be_false } } }
    it { expect(action).not_to pass }
  end
end