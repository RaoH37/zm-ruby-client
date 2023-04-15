# frozen_string_literal: true

module Zm
  module Client
    # Class Builder [Domain]
    class DomainsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :domain
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          DomainJsnsInitializer.create(@parent, entry)
        end
      end
    end
  end
end
