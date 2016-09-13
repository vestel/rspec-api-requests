require 'spec_helper'
require 'rspec-api/respond_with'

describe 'respond_with', sandboxing: true do
  include RSpecApi::RespondWith
  include RSpec::Core::DSL

  let(:status) { :ok }
  let(:given_values) { {} }
  let(:block) { nil }
  let(:route) { '/' }
  let(:action) { 'get' }
  let(:host) { 'http://example.com' }
  let(:authorize_with) { nil }
  let(:adapter) { [:net_http] }
  let(:throttle) { nil }
  let(:collection) { nil }
  let(:attributes) { nil }
  let(:extra_requests) { [] }
  let(:rspec_api_params) { {action: action, route: route, host: host,
    authorize_with: authorize_with, adapter: adapter, throttle: throttle,
    collection: collection, attributes: attributes, extra_requests: extra_requests} }
  let(:example) { respond_with status, given_values, &block }

  let(:headers) { {'Content-Type' => 'application/json; charset=utf-8'} }
  let(:body) { '[{"key":"fake"},{"key":"collection"}]' }
  let(:response) { OpenStruct.new status: 200, headers: headers, body: body}

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
    let(:host) { 'http://example.org' }
    it 'uses the host for the request' do
      expect(Faraday).to receive(:new).with('http://example.org').and_call_original
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).to pass
    end
  end

  context 'given a valid action' do
    let(:action) { 'put' }
    it 'uses the action for the request' do
      expect_any_instance_of(Faraday::Connection).to receive(:put).and_return(response)
      expect(example).to pass
    end
  end

  context 'given a valid authorize_with' do
    let(:authorize_with) { [:token, '123'] }
    it 'uses the authorize_with for the request' do
      expect_any_instance_of(Faraday::Connection).to receive(:authorization).with(*authorize_with)
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).to pass
    end
  end

  context 'given a valid adapter' do
    let(:adapter) { [:rack, 'app'] }
    it 'uses the adapter for the request' do
      expect_any_instance_of(Faraday::Connection).to receive(:adapter).with(*adapter)
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).to pass
    end
  end

  context 'given a valid throttle' do
    let(:throttle) { 1 }
    it 'sleeps for the number of seconds before the request' do
      # TODO !
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).to pass
    end
  end

  context 'given an expected status that does not match the response status' do
    let(:status) { :no_content }
    it 'does not pass' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).not_to pass
    end
  end

  context 'given an expected status that matches the response status' do
    let(:status) { :ok }
    context 'given no block' do
      let(:block) { nil }
      it 'passes' do
        expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
        expect(example).to pass
      end
    end

    context 'given a passing block with no arguments' do
      let(:block) { Proc.new { expect(true).to be_true } }
      it 'passes' do
        expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
        expect(example).to pass
      end
    end

    context 'given a failing block with no arguments' do
      let(:block) { Proc.new { expect(true).to be_false } }
      it 'does not pass' do
        expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
        expect(example).not_to pass
      end
    end

    context 'given a block with one argument' do
      let(:block) { resp = response; Proc.new {|arg1| expect(arg1).to eq resp} }
      it 'passes the response as the first argument of the block' do
        expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
        expect(example).to pass
      end
    end
  end

  context 'given the response matches the collection expectation' do
    let(:collection) { true }
    it 'passes' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).to pass
    end
  end

  context 'given the response does not match the collection expectation' do
    let(:collection) { false }
    it 'does not pass' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).not_to pass
    end
  end

  context 'given the response matches the attributes expectation' do
    let(:attributes) { {key: {type: :string}} }
    it 'passes' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).to pass
    end
  end

  context 'given the response does not match the attributes expectation' do
    let(:attributes) { {key: {type: :number}} }
    it 'does not pass' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example).not_to pass
    end
  end

  context 'given extra requests' do
    let(:extra_requests) { [{}] }
    context 'on a non-collection' do
      let(:body) { '{"an":"object"}' }
      let(:collection) { false }
      it 'does not run extra requests' do
        expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
        expect(example).to pass
        expect(example).not_to be_an(Array)
      end
    end

    context 'on a collection' do
      let(:collection) { true }
      before do
        faraday = double(Faraday.new, headers: {}, get: response)
        expect(Faraday).to receive(:new).exactly(2).times.and_return(faraday)
      end

      it 'runs extra requests' do
        expect(example.length).to be 2
      end

      context 'given any extra request fails' do
        let(:extra_requests) { [{expect: {sort: {by: :key}}, params: {sorted: true}}] }
        it 'does not pass' do
          expect(example.last).not_to pass
        end
      end


      context 'given all the extra requests pass' do
        let(:extra_requests) { [{expect: {sort: {by: :key, verse: :desc}}, params: {sorted: true}}] }
        it 'passes' do
          expect(example.last).to pass
        end
      end
    end
  end

  context 'given a parameter that matches a placeholder in the route' do
    let(:route) { '/:id' }
    let(:given_values) { {id: 123} }
    it 'replaces the parameter in the route' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example.description).to eq 'GET /123'
    end

    context 'given a block' do
      let(:block) { Proc.new {|_, arg2| expect(arg2[:id]).to eq 123 } }
      it 'makes the parameter available in the second argument of the block' do
        expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
        expect(example).to pass
      end
    end
  end

  context 'given a url_type get parameter that matches a placeholder in the route' do
    let(:route) { '/endpoint?param=:id' }
    let(:given_values) { {id: 123} }
    it 'replaces the parameter in the route' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
      expect(example.description).to eq 'GET /endpoint?param=123'
    end
  end

  context 'given a parameter that does not match a placeholder in the route' do
    let(:given_values) { {id: 123} }
    it 'passes the parameter to the body request' do
      expect_any_instance_of(Faraday::Connection).to receive(action).and_return(response)
    # NOTE: I might use to_query, but it would not distinguish between
    #       query params and POST body content
      expect(example.description).to eq 'GET / with {:id=>123}'
    end
  end
end