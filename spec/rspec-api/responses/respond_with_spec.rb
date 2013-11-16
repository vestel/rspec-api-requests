# respond_with does the following:

# 1. replaces the options in the routes (prefix and  query params)
# 2. reads action, route (and then host, auth) from metadata and sends the request
# 3. invokes expect_response on the response
# 4. runs the expectations in the block

# picks EITHER local OR remote based on:
# if there is no host then it's assumed to be local
# or maybe the route is already a URL, like GET http://

# let's start with only 2. and 3.

require 'spec_helper'
require 'rspec-api/responses'

describe 'respond_with', sandboxing: true do
  include RSpecApi::Responses

  let(:route) { '/' }
  let(:rspec_api) { {host: 'http://example.com', route: route, action: :get, collection: collection} }
  let(:status) { :ok }
  let(:params) { {} }
  let(:block) { nil }
  let(:collection) { false }
  let(:example) { respond_with status, params, &block }

  context 'given no parameters' do
    let(:params) { {} }
    it { expect(example.description).to eq 'at /' }

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
      let(:collection) { false }
      it { expect(example).to pass }
    end

    context 'given the response does not match the collection expectation' do
      let(:collection) { true }
      it { expect(example).not_to pass }
    end
  end

  context 'given a parameter that matches a placeholder in the route' do
    let(:route) { '/:id' }
    let(:params) { {id: 123} }
    it 'replaces the parameter in the route' do
      expect(example.description).to eq 'at /123'
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
    let(:params) { {id: 123} }
    # NOTE: I might use to_query, but it would not distinguish between
    #       query params and POST body content
    it { expect(example.description).to eq 'at / with {:id=>123}' }
  end

  context 'not given host, route and action' do
    let(:rspec_api) { {} }
    it { expect(example).to be_pending_with %r|specify host, route, and action| }
  end
end