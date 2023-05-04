# frozen_string_literal: true

module Zm
  module Client
    # Collection coses
    class CosesCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Cos
        @builder_class = CosesBuilder
        @search_type = SearchType::COS
        super(parent)
      end

      def find_by!(hash)
        # rep = sac.get_cos(hash.values.first, hash.keys.first, attrs_comma)
        # entry = rep[:Body][:GetCosResponse][:cos].first

        soap_request = SoapElement.new(SoapAdminConstants::GET_COS_REQUEST, SoapAdminConstants::NAMESPACE_STR)
        node_cos = SoapElement.new('cos', nil).add_attribute('by', hash.keys.first).add_content(hash.values.first)
        soap_request.add_node(node_cos)
        soap_request.add_attribute('attrs', attrs_comma)
        entry = sac.invoke(soap_request)[:GetCosResponse][:cos].first

        reset_query_params
        CosJsnsInitializer.create(@parent, entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::COS.dup
      end
    end
  end
end
