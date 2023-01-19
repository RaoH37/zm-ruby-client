# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class DomainDistributionListsCollection < DistributionListsCollection
      def initialize(parent)
        super(parent)
        @domain_name = parent.name
      end
    end
  end
end
