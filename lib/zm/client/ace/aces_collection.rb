# frozen_string_literal: true

module Zm
  module Client
    # collection account aces
    class AcesCollection < Base::AccountObjectsCollection
      attr_reader :rights

      def initialize(parent)
        super(parent)
        @child_class = Ace
        @builder_class = AcesBuilder
        @jsns_builder = AceJsnsBuilder.new(self)
        reset_query_params
      end

      def where(*rights)
        @rights += rights
        @rights.uniq!
        self
      end

      private

      def make_query
        @parent.sacc.invoke(@jsns_builder.to_find)
      end

      def reset_query_params
        @rights = []
      end
    end
  end
end
