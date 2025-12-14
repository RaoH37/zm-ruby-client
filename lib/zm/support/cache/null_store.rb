# frozen_string_literal: true

module Zm
  module Support
    module Cache
      class NullStore < Store
        Cache.register_storage(:null_store, self)

        def fetch(_name, _options = nil, &block)
          block.call
        end

        def read(_name, _options = nil)
          nil
        end

        def write(_name, _value, _options = nil)
          nil
        end

        def delete(_name, _options = nil)
          nil
        end

        def exist?(_name, _options = nil)
          false
        end

        def clear(_options = nil)
          nil
        end

        def cleanup(_options = nil)
          nil
        end

        def inspect # :nodoc:
          "#<#{self.class.name} options=#{@options.inspect}>"
        end
      end
    end
  end
end
