# frozen_string_literal: true

module Zm
  module Support
    module Cache
      DeserializationError = Class.new(StandardError)

      class << self
        def registered_storage
          @registered_storage ||= {}
        end

        def register_storage(key, klass)
          registered_storage[key] = klass
        end
      end
    end
  end
end

require 'zm/support/cache/entry'
require 'zm/support/cache/strategy'
require 'zm/support/cache/request_strategy'
require 'zm/support/cache/store'
require 'zm/support/cache/null_store'
require 'zm/support/cache/file_store'
