# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources from domain
    class DomainResourcesCollection < ResourcesCollection
      def initialize(parent)
        super(parent)
        @domain_name = parent.name
      end
    end
  end
end
