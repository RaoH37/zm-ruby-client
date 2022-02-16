# frozen_string_literal: true

module Zm
  module Client
    # Class Builder [Domain]
    class DomainsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Domain
        @json_item_key = :domain
      end
    end
  end
end
