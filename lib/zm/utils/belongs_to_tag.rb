# frozen_string_literal: true

module Zm
  module Utils
    module BelongsToTag
      def tags
        return @tags if defined? @tags

        @tags = AccountObjectTagsCollection.new(self)
      end
    end
  end
end
