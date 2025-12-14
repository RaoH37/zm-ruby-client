# frozen_string_literal: true

module Zm
  module Client
    # Collection coses
    class CosesCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Cos
        @builder_class = CosesBuilder
        @search_type = SearchType::COS
        super
      end

      def find_by!(hash)
        soap_request = SoapElement.admin(SoapAdminConstants::GET_COS_REQUEST)
        node_cos = SoapElement.create(SoapConstants::COS)
                              .add_attribute(SoapConstants::BY, hash.keys.first)
                              .add_content(hash.values.first)
        soap_request.add_node(node_cos)
        soap_request.add_attribute(SoapConstants::ATTRS, attrs_comma)
        entry = sac.invoke(soap_request)[:GetCosResponse][:cos].first

        reset_query_params
        CosJsnsInitializer.create(@parent, entry)
      end

      def clone!(new_name, &)
        cos = Cos.new(parent, &)
        cos.clone!(new_name)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::COS.dup
      end
    end
  end
end
