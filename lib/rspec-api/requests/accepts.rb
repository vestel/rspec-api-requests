module RSpecApi
  module Requests
    module Accepts
      def accepts(options = {})
        # accepts_filter options if options.keys.include? :filter
        accepts_sort options if options.keys.include? :sort
        accepts_page options if options.keys.include? :page
        # accepts_callback options if options.keys.include? :callback
      end

    private

      def accepts_sort(options = {})
        (rspec_api[:extra_requests] ||= []) << {
          params: {sort: options[:sort]}.merge(options.fetch :sort_if, {}),
          expect: {sort: options.slice(:by, :verse)}
        }
      end

      def accepts_page(options = {})
        (rspec_api[:extra_requests] ||= []) << {
          params: {}.tap{|params| params[options[:page]] = 2},
          expect: {page_links: true}
        }
      end

      def rspec_api
        defined?(metadata) ? metadata : example.metadata
      end
    end
  end
end

