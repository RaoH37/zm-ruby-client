# frozen_string_literal: true

module Zm
  module Support
    module Cache
      DeserializationError = Class.new(StandardError)

      autoload :Entry, 'zm/support/cache/entry'
      autoload :Strategy, 'zm/support/cache/strategy'
      autoload :RequestStrategy, 'zm/support/cache/request_strategy'
      autoload :Store, 'zm/support/cache/store'
      autoload :NullStore, 'zm/support/cache/null_store'
      autoload :FileStore, 'zm/support/cache/file_store'

      class << self
        def registered_storage
          @registered_storage ||= { null_store: :NullStore, file_store: :FileStore }
        end

        def register_storage(key, klass)
          registered_storage[key] = klass
        end

        def storage(key)
          klass = registered_storage[key]
          klass.is_a?(Symbol) ? const_get(klass) : klass
        end
      end
    end
  end
end
