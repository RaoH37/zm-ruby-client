# frozen_string_literal: true

module Zm
  module Client
    # collection account tags
    class TagsCollection < Base::AccountObjectsCollection
      def initialize(parent)
        @child_class = Tag
        @builder_class = TagBuilder
        super(parent)
      end

      private

      def make_query
        @parent.sacc.jsns_request(:GetTagRequest, @parent.token, nil)
      end
    end
  end
end
