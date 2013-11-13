module RSpecApi
  module Requests
    module Actions
      [:get, :put, :patch, :post, :delete].each do |action|
        define_method action do |route, options = {}, &block|
          RSpec::Core::ExampleGroup.describe "#{action.upcase} #{route}", action: action, route: route do
            instance_eval &block if block
          end
        end
      end
    end
  end
end
