require 'spec_helper'
require 'rspec-api/requests'

describe 'accepts', sandboxing: true do
  include RSpecApi::Requests

  context 'given a sort accept' do
    let(:block) { Proc.new {
      should_have_extra_requests [
        {params: {sort: :place}, expect: {sort: {by: :location}}},
        {params: {sort: :time},  expect: {sort: {by: :created_at}}}
      ] } }
    let(:action) {
      accepts sort: :place, by: :location
      accepts sort: :time, by: :created_at
      get '/concerts', params, &block
    }

    context 'given an action that does not override the extra_requests' do
      let(:params) { {} }
      it { expect(action).to pass }
    end

    context 'given an action that overrides the extra_requests' do
      let(:params) { {extra_requests: []} }
      it { expect(action).not_to pass }
    end
  end

  context 'given a page accept' do
    let(:block) { Proc.new {
      should_have_extra_requests [
        {params: {p: 2}, expect: {page_links: true}}
      ] } }
    let(:action) {
      accepts page: :p
      get '/concerts', params, &block
    }

    let(:params) { {} }
    it { expect(action).to pass }
  end

  context 'given a callback accept' do
    let(:block) { Proc.new {
      should_have_extra_requests [
        {params: {alert: 'anyCallback'}, expect: {callback: 'anyCallback'}}
      ] } }
    let(:action) {
      accepts callback: :alert
      get '/concerts', params, &block
    }

    let(:params) { {} }
    it { expect(action).to pass }
  end
end