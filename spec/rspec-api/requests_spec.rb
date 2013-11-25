require 'spec_helper'
require 'rspec-api/requests'

describe RSpecApi::Requests do
  context 'inside example groups tagged as :rspec_api', :rspec_api do
    describe 'describe blocks' do
      should_respond_to :respond_with
    end
  end

  context 'inside example groups that extend RSpecApi::Requests' do
    extend RSpecApi::Requests
    describe 'describe blocks' do
      should_respond_to :respond_with
    end
  end
  
  context 'inside other example groups' do
    describe 'describe blocks' do
      should_not_respond_to :respond_with
    end
  end
end