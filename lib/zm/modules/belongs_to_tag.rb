# frozen_string_literal: true

module Zm
  module Client
    module BelongsToTag
      def tags
        return @tags if defined? @tags

        @tags = AccountObject::TagsCollection.new(self)
      end
    end
  end
end
