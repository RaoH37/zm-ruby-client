# frozen_string_literal: true

module Zm
  module Client
    # Collection Accounts from cos
    class CosAccountsCollection < AccountsCollection
      def build_response
        ldap_filter.add(default_ldap_filter)

        super
      end

      def default_ldap_filter
        domain_filter = @parent.domains.all.map { |domain| "(zimbraMailDeliveryAddress=*@#{domain.name})" }.join
        "(|(zimbraCOSId=#{@parent.id})(&(!(zimbraCOSId=*))(|#{domain_filter})))"
      end
    end
  end
end
