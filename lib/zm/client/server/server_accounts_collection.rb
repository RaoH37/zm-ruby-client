# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts from server
    class ServerAccountsCollection < AccountsCollection
      def initialize(parent)
        @target_server_id = parent.id
        super(parent)
      end

      private

      def ldap_filter
        @ldap_filter ||= LdapFilter.new("(zimbraMailHost=#{@parent.name})")
      end
    end
  end
end
