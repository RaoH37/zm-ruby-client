# frozen_string_literal: true

module Zm
  module Client
    # class factory [messages]
    class MessagesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
        # puts json
      end

      def make
        root.map do |entry|
          MessageJsnsInitializer.create(@parent, entry)
        end
      end

      def ids
        @json[:Body][:SearchResponse][:hit].map { |s| s[:id] }
      end

      def root
        root = @json[:Body][:SearchResponse][:m]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root
      end
    end
  end
end
