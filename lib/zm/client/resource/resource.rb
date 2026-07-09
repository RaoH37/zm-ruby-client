# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::MailboxObject
      include SoapRequest::RequestMethodsAdmin

      has_jsns_builder

      LOCATION = 'Location'
      EQUIPMENT = 'Equipment'
      TYPES = [LOCATION, EQUIPMENT].freeze

      def create!
        resp = sac.invoke(build_create)
        @id = resp[:CreateCalendarResourceResponse][:calresource].first[:id]
      end

      def attrs_write
        @parent.zimbra_attributes.all_resource_attrs_writable_names
      end

      def location?
        zimbraCalResType == LOCATION
      end

      def equipment?
        zimbraCalResType == EQUIPMENT
      end
    end
  end
end
