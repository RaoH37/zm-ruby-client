# frozen_string_literal: true

module Zm
  module Client
    # collection of signatures
    class SignaturesCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
      end

      def new
        signature = Signature.new(@parent)
        yield(signature) if block_given?
        signature
      end

      private

      def build_response
        rep = @parent.sacc.get_signatures(@parent.token)
        sb = SignaturesBuilder.new @parent, rep
        sb.make
      end
    end
  end
end
