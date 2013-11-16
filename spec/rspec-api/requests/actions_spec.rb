require 'spec_helper'
require 'rspec-api/requests'

describe 'get' do # For brevity, since :put, :patch, :delete, :post are similar
  include RSpecApi::Requests

  let(:block) { nil }
  let(:action) { get '/concerts', &block }

  it { expect(action.description).to eq 'GET /concerts'}
  it { expect(action.metadata[:action]).to eq :get }
  it { expect(action.metadata[:route]).to eq '/concerts' }

  context 'responds to `respond_with` in the given block', sandboxing: true do
    let(:block) { Proc.new { should_respond_to :respond_with } }
    it { expect(action).to pass }
  end

  context 'passes when given a passing block', sandboxing: true do
    let(:block) { Proc.new { it { expect(true).to be_true } } }
    it { expect(action).to pass }
  end

  context 'fails when given a failing block', sandboxing: true do
    let(:block) { Proc.new { it { expect(true).to be_false } } }
    it { expect(action).not_to pass }
  end

  # TODO: Add tests for which options are passed to `respond_with`, e.g.
  # the extra_requests are only passed for collections
end