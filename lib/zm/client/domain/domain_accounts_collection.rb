# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts from domain
    class DomainAccountsCollection < AccountsCollection
      def initialize(parent)
        super(parent)
        @domain_name = parent.name
      end
    end
  end
end
