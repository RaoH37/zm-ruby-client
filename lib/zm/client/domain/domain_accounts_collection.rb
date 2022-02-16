# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts from domain
    class DomainAccountsCollection < AccountsCollection
      def initialize(parent)
        @domain_name = parent.name
        super(parent)
      end
    end
  end
end
