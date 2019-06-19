# frozen_string_literal: true

module Zm
  module Client
    # class factory [tags]
    class TagBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root = @json[:Body][:GetTagResponse][:tag]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root.map do |s|
          tag = Tag.new(@parent)
          tag.init_from_json(s)
          tag
        end
      end
    end
  end
end
