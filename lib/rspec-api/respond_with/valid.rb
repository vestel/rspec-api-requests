module RSpecApi
  module RespondWith
    module Valid
      def valid?(opts = {})
        opts.any? && opts.key?(:route) && opts.key?(:action) && (opts.key?(:host) || opts.key?(:adapter))
      end
    end
  end
end