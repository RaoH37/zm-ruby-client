# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class DomainsCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Domain
        @builder_class = DomainsBuilder
        @search_type = SearchType::DOMAIN
        super(parent)
      end

      def find_by!(hash)
        soap_request = SoapElement.admin(SoapAdminConstants::GET_DOMAIN_REQUEST)
        node_domain = SoapElement.create(SoapConstants::DOMAIN)
                                 .add_attribute(SoapConstants::BY, hash.keys.first)
                                 .add_content(hash.values.first)
        soap_request.add_node(node_domain)
        soap_request.add_attribute(SoapConstants::ATTRS, attrs_comma)
        entry = sac.invoke(soap_request)[:GetDomainResponse][:domain].first

        reset_query_params
        DomainJsnsInitializer.create(@parent, entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::DOMAIN.dup
      end
    end
  end
end
