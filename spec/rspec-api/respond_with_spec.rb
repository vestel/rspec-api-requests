require 'spec_helper'
require 'rspec-api/respond_with'

describe 'respond_with', sandboxing: true do
  include RSpecApi::RespondWith

  let(:status) { :ok }
  let(:given_values) { {} }
  let(:block) { nil }
  let(:route) { '/' }
  let(:rspec_api_params) { {action: 'get', route: route, host: 'http://example.com'} }
  let(:example) { respond_with status, given_values, &block }

  context 'given the action rspec_api_params metadata is missing' do
    let(:rspec_api_params) { {route: '/', host: 'http://api.example.com'} }
    it { expect(example).to be_pending_with %r|specify the parameters| }
  end

  context 'given the route rspec_api_params metadata is missing' do
    let(:rspec_api_params) { {action: 'get', host: 'http://api.example.com'} }
    it { expect(example).to be_pending_with %r|specify the parameters| }
  end

  context 'given the host and adapter rspec_api_params metadata are missing' do
    let(:rspec_api_params) { {action: 'get', route: '/'} }
    it { expect(example).to be_pending_with %r|specify the parameters| }
    it { expect(example.description).to eq 'GET /' }
  end

  context 'given a valid host' do
    let(:rspec_api_params) { {action: 'get', route: route, host: 'http://example.com'} }
    it 'uses the host for the request' do
      expect(Faraday).to receive(:new).with('http://example.com').and_call_original
      expect(example).to pass
    end
  end

  context 'given a valid action' do
    let(:rspec_api_params) { {action: 'get', route: route, host: 'http://example.com'} }
    it 'uses the action for the request' do
      expect_any_instance_of(Faraday::Connection).to receive(:get).and_call_original
      expect(example).to pass
    end
  end

  context 'given a valid authorize_with' do
    let(:rspec_api_params) { {action: 'get', route: route, host: 'http://example.com', authorize_with: {token: '123'}} }
    it 'uses the action for the request' do
      expect_any_instance_of(Faraday::Connection).to receive(:authorization).with(:token, '123').and_call_original
      expect(example).to pass
    end
  end

  context 'given a valid adapter' do
    let(:rspec_api_params) { {action: 'get', route: route, host: 'http://example.com', adapter: [:net_http]} }
    it 'uses the action for the request' do
      expect_any_instance_of(Faraday::Connection).to receive(:adapter).with(:net_http).and_call_original
      expect(example).to pass
    end
  end

  context 'given a valid throttle' do
    let(:rspec_api_params) { {action: 'get', route: route, host: 'http://example.com', throttle: 1} }
  end

  context 'given an expected status that does not match the response status' do
    let(:status) { :not_found }
    it { expect(example).not_to pass }
  end

  context 'given an expected status that matches the response status' do
    let(:status) { :ok }
    context 'given no block' do
      let(:block) { nil }
      it { expect(example).to pass }
    end

    context 'given a passing block with no arguments' do
      let(:block) { Proc.new { expect(true).to be_true } }
      it { expect(example).to pass }
    end

    context 'given a failing block with no arguments' do
      let(:block) { Proc.new { expect(true).to be_false } }
      it { expect(example).not_to pass }
    end

    context 'given a block with one argument' do
      let(:block) { Proc.new {|arg1| expect(arg1.status).to eq 200} }
      it 'passes the response as the first argument of the block' do
        expect(example).to pass
      end
    end
  end

  context 'given the response matches the collection expectation' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', collection: false} }
    it { expect(example).to pass }
  end

  context 'given the response does not match the collection expectation' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', collection: true} }
    it { expect(example).not_to pass }
  end

  context 'given the response matches the attributes expectation' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', attributes: {}} }
    it { expect(example).to pass }
  end

  context 'given the response does not match the attributes expectation' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', attributes: {id: {type: :string}}} }
    it { expect(example).not_to pass }
  end

  context 'given extra requests on a non-collection' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', extra_requests: [{}, {}]} }
    it 'runs one more request for each extra request' do
      expect(example).not_to be_an(Array)
    end
  end

  context 'given extra requests on a collection' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', collection: true, extra_requests: [{}, {}]} }
    it 'runs one more request for each extra request' do
      expect(example.length).to eq 3
    end
  end

  # TODO: write a passing one -- this fails because it's not a collection
  # context 'given a passing extra requests' do
  #   let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', collection: true, extra_requests: [{}]} }
  #   it { debugger; expect(example.last).to pass }
  # end

  context 'given a failing extra request' do
    let(:rspec_api_params) { {action: 'get', route: '/', host: 'http://example.com', collection: true, extra_requests: [{expect: {sort: {by: :id}}, params: {foo: :bar}}]} }
    it { expect(example.last).not_to pass }
  end

  context 'given a parameter that matches a placeholder in the route' do
    let(:route) { '/:id' }
    let(:given_values) { {id: 123} }
    it 'replaces the parameter in the route' do
      expect(example.description).to eq 'GET /123'
    end

    context 'given a block' do
      let(:status) { :not_found }
      let(:block) { Proc.new {|arg1, arg2| expect(arg2[:id]).to eq 123 } }
      it 'makes the parameter available in the second argument of the block' do
        expect(example).to pass
      end
    end
  end

  context 'given a parameter that does not match a placeholder in the route' do
    let(:given_values) { {id: 123} }
    # NOTE: I might use to_query, but it would not distinguish between
    #       query params and POST body content
    it { expect(example.description).to eq 'GET / with {:id=>123}' }
  end
end