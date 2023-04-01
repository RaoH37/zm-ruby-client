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

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          IdentityJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
