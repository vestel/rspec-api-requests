module RSpecApi
  module Requests
    module Accepts
      def accepts(options = {})
        add_request_for accepts_sort(options) if options.key? :sort
        add_request_for accepts_filter(options) if options.key? :filter
        add_request_for accepts_page(options) if options.key? :page
        add_request_for accepts_callback(options) if options.key? :callback
      end

    private

      def add_request_for(opts = {})
        (rspec_api[:accept_requests] ||= []) << opts
      end

      def accepts_sort(opts = {})
        {params: sort_params(opts), expect: sort_expect(opts)}
      end

      def sort_params(opts = {})
        {sort: opts[:sort]}.merge(opts.fetch :sort_if, {})
      end

      def sort_expect(opts = {})
        {sort: opts.slice(:by, :verse)}
      end

      def accepts_filter(opts = {})
        {params: filter_params(opts), expect: filter_expect(opts)}
      end

      def filter_params(opts = {})
        {}.tap{|params| params[opts[:filter]] = opts[:value]}
      end

      def filter_expect(opts = {})
        {filter: opts.slice(:by, :compare_with, :value)}
      end

      def accepts_page(opts = {})
        {params: page_params(opts), expect: page_expect(opts)}
      end

      def page_params(opts = {})
        {}.tap{|params| params[opts[:page]] = 2}
      end

      def page_expect(opts = {})
        {page_links: true}
      end

      def accepts_callback(opts = {})
        # NOTE: This is the only accepts that affects *all* the requests,
        #       not just the ones that return a collection
        {params: callback_params(opts), expect: callback_expect(opts), all: true}
      end

      def callback_params(opts = {})
        {}.tap{|params| params[opts[:callback]] = 'anyCallback'}
      end

      def callback_expect(opts = {})
        {callback: 'anyCallback'}
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end

