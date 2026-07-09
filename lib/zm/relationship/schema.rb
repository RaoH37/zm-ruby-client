# frozen_string_literal: true

module Zm
  module Relationship
    class Schema
      include Enumerable

      def initialize(properties_index: {})
        @properties_index = properties_index
        @mutex = Mutex.new
      end

      attr_reader :properties_index

      def [](key)
        @properties_index[key]
      end

      def keys
        @properties_index.keys
      end

      def <<(value)
        @mutex.synchronize do
          @properties_index[value.name] = value
        end

        self
      end
    end
  end
end
