# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class ResourcesCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Resource
        @builder_class = ResourcesBuilder
        @search_type = :resources
        super
      end

      def find_by!(hash)
        entry = sac.invoke(build_find_by(hash))[:GetCalendarResourceResponse][:calresource].first

        reset_query_params
        ResourceJsnsInitializer.create(@parent, entry)
      end

      def build_find_by(hash)
        soap_request = SoapRequest::SoapElement.admin(Zm::SoapRequest::SoapAdminConstants::GET_CALENDAR_RESOURCE_REQUEST)
        node_res = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::CAL_RESOURCE)
                              .add_attribute(SoapRequest::SoapConstants::BY, hash.keys.first)
                              .add_content(hash.values.first)
        soap_request.add_node(node_res)
        soap_request.add_attribute(SoapRequest::SoapConstants::ATTRS, attrs_comma)
        soap_request.add_attribute(SoapRequest::SoapConstants::APPLY_COS, @apply_cos)
        soap_request
      end

      private

      def reset_query_params
        super
        @attrs = :resources
      end
    end
  end
end
