require 'spec_helper'
require 'rspec-api/requests'

actions = [:get, :put, :post, :patch, :delete]
methods = actions #+ [:host, :authorize_with, :has_attribute]

describe RSpecApi::Requests do
  context 'example groups tagged as :rspec_api', :rspec_api do
    methods.each{|method| should_respond_to method}
  end

  context 'example groups that include RSpecApi::Expectations' do
    extend RSpecApi::Requests
    methods.each{|method| should_respond_to method}
  end

  context 'other example groups' do
    methods.each{|method| should_not_respond_to method}
  end
end