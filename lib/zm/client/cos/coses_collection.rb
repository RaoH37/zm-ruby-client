# frozen_string_literal: true

module Zm
  module Client
    # Collection coses
    class CosesCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Cos
        @builder_class = CosesBuilder
        @search_type = :coses
        super
      end

      def find_by!(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_COS_REQUEST)
        node_cos = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::COS)
                              .add_attribute(SoapRequest::SoapConstants::BY, hash.keys.first)
                              .add_content(hash.values.first)
        soap_request.add_node(node_cos)
        soap_request.add_attribute(SoapRequest::SoapConstants::ATTRS, attrs_comma)
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
        @attrs = %w[
          cn
          description
          zimbraMailHostPool
          zimbraMailQuota
        ]
      end
    end
  end
end
