# frozen_string_literal: true

module Zm
  module Client
    # class factory [messages]
    class MessagesBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
      end

      def make
        root.map do |s|
          Message.new(@account, s)
        end
      end

      def ids
        hits = @json.dig(:Body, :SearchResponse, :hit) || []
        hits.map { |s| s[:id] }
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
