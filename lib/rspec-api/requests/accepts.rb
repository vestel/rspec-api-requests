module RSpecApi
  module Requests
    module Accepts
      def accepts(options = {})
        extra_request = if options.keys.include? :sort
          accepts_sort options
        elsif options.keys.include? :page
          accepts_page options
        elsif options.keys.include? :callback
          accepts_callback options
        end
        (rspec_api[:extra_requests] ||= []) << extra_request if extra_request
        # accepts_filter options if options.keys.include? :filter
      end

    private

      def accepts_sort(options = {})
        {
          params: {sort: options[:sort]}.merge(options.fetch :sort_if, {}),
          expect: {sort: options.slice(:by, :verse)}
        }
      end

      def accepts_page(options = {})
        {
          params: {}.tap{|params| params[options[:page]] = 2},
          expect: {page_links: true}
        }
      end

      def accepts_callback(options = {})
        {
          params: {}.tap{|params| params[options[:callback]] = 'anyCallback'},
          expect: {callback: 'anyCallback'}
        }
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end

