# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class DistributionListsCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = DistributionList
        @builder_class = DistributionListsBuilder
        @search_type = SearchType::DL
        super(parent)
      end

      def find_by!(hash)
        entry = sac.invoke(build_find_by(hash))[:GetDistributionListResponse][:dl].first

        reset_query_params
        DistributionListJsnsInitializer.create(@parent, entry)
      end

      def build_find_by(hash)
        soap_request = SoapElement.admin(SoapAdminConstants::GET_DISTRIBUTION_LIST_REQUEST)
        node_dl = SoapElement.create(SoapConstants::DL)
                             .add_attribute(SoapConstants::BY, hash.keys.first)
                             .add_content(hash.values.first)
        soap_request.add_node(node_dl)
        soap_request.add_attribute(SoapConstants::ATTRS, attrs_comma)
        soap_request
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::DL.dup
      end
    end
  end
end
