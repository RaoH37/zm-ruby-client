# frozen_string_literal: true

module Zm
  module Client
    # class factory [identities]
    class IdentitiesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Identity
        @json_item_key = :identity
      end
    end
  end
end
