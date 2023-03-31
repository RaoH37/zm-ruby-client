# frozen_string_literal: true

module Zm
  module Client
    # collection account identitys
    class IdentitiesCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
      end

      def new
        identity = Identity.new(@parent)
        yield(identity) if block_given?
        identity
      end

      private

      def build_response
        rep = @parent.sacc.get_all_identities(@parent.token)
        ib = IdentitiesBuilder.new @parent, rep
        ib.make
      end
    end
  end
end
