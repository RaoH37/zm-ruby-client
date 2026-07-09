# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class DomainsCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Domain
        @builder_class = DomainsBuilder
        @search_type = :domains
        super
      end

      def find_by!(hash)
        entry = sac.invoke(build_find_by(hash))[:GetDomainResponse][:domain].first

        reset_query_params
        DomainJsnsInitializer.create(@parent, entry)
      end

      def build_find_by(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_DOMAIN_REQUEST)
        node_domain = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::DOMAIN)
                                 .add_attribute(SoapRequest::SoapConstants::BY, hash.keys.first)
                                 .add_content(hash.values.first)
        soap_request.add_node(node_domain)
        soap_request.add_attribute(SoapRequest::SoapConstants::ATTRS, attrs_comma)
        soap_request
      end

      private

      def reset_query_params
        super
        @attrs = %w[
          description
          zimbraDomainName
          zimbraDomainStatus
          zimbraId
          zimbraDomainType
          zimbraDomainDefaultCOSId
        ]
      end
    end
  end
end
