# frozen_string_literal: true

module Zm
  module Client
    # collection account aces
    class AcesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def new
        ace = Ace.new(@parent)
        yield(ace) if block_given?
        ace
      end

      def rights(*rights)
        @rights = rights
        self
      end

      private

      def build_response
        rep = @parent.sacc.get_rights(@parent.token, @rights)
        ab = AcesBuilder.new @parent, rep
        ab.make
      end

      def reset_query_params
        @rights = %i[sendAs sendOnBehalfOf]
      end
    end
  end
end
