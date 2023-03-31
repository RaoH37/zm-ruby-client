# frozen_string_literal: true

module Zm
  module Client
    # collection account tags
    class TagsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def new
        tag = Tag.new(@parent)
        yield(tag) if block_given?
        tag
      end

      private

      def build_response
        rep = @parent.sacc.get_tag(@parent.token)
        tb = TagBuilder.new @parent, rep
        tb.make
      end
    end
  end
end
