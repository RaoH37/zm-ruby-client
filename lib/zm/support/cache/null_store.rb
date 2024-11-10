# frozen_string_literal: true

module Zm
  module Support
    module Cache
    class NullStore < Store
      Cache.register_storage(:null_store, self)

      def fetch(name, options = nil, &block)
        block.call
      end

      def read(name, options = nil)
        nil
      end

      def write(name, value, options = nil)
        nil
      end

      def delete(name, options = nil)
        nil
      end

      def exist?(name, options = nil)
        false
      end

      def clear(options = nil)
        nil
      end

      def cleanup(options = nil)
        nil
      end

      def inspect # :nodoc:
        "#<#{self.class.name} options=#{@options.inspect}>"
      end
    end
  end
end
end
