module RSpecApi
  module Requests
    module HasAttribute
      def has_attribute(name, options, &block)
        if block_given?
          options[:type] = Hash[options[:type], {}]
          nest_attributes options[:type], &Proc.new
        end
        if @attribute_ancestors.present?
          hash = @attribute_ancestors.last
          hash.each{|type, _| (hash[type] ||= {})[name] = options}
        else
          (rspec_api[:attributes] ||= {})[name] = options
        end
      end

      def nest_attributes(hash, &block)
        (@attribute_ancestors ||= []).push hash
        yield
        @attribute_ancestors.pop
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end