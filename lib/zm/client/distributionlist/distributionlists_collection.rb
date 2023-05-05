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
        # rep = sac.get_distribution_list(hash.values.first, hash.keys.first, attrs_comma)
        # entry = rep[:Body][:GetDistributionListResponse][:dl].first

        soap_request = SoapElement.new(SoapAdminConstants::GET_DISTRIBUTION_LIST_REQUEST, SoapAdminConstants::NAMESPACE_STR)
        node_dl = SoapElement.new('dl', nil).add_attribute('by', hash.keys.first).add_content(hash.values.first)
        soap_request.add_node(node_dl)
        soap_request.add_attribute('attrs', attrs_comma)
        entry = sac.invoke(soap_request)[:GetDistributionListResponse][:dl].first

        reset_query_params
        DistributionListJsnsInitializer.create(@parent, entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::DL.dup
      end
    end
  end
end
