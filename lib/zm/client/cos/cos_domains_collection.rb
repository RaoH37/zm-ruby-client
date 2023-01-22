# frozen_string_literal: true

module Zm
  module Client
    # Collection Domains for cos
    class CosDomainsCollection < DomainsCollection
      def initialize(parent)
        super(parent)

        @default_ldap_filter = "(zimbraDomainDefaultCOSId=#{@parent.id})"
      end

      def build_response
        ldap_filter.add(@default_ldap_filter)

        super
      end
    end
  end
end
