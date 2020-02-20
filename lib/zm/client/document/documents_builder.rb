# frozen_string_literal: true

module Zm
  module Client
    # class factory [documents]
    class DocumentsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root.map do |s|
          Document.new(@parent, s)
        end
      end

      def ids
        root.map { |s| s[:id] }
      end

      def root
        root = @json[:Body][:SearchResponse][:doc]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root
      end
    end
  end
end
