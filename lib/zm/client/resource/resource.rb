# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::MailboxObject
      include RequestMethodsAdmin

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

      def jsns_builder
        @jsns_builder ||= ResourceJsnsBuilder.new(self)
      end
    end
  end
end
