# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::MailboxObject
      LOCATION = 'Location'
      EQUIPMENT = 'Equipment'
      TYPES = [LOCATION, EQUIPMENT].freeze

      def delete!
        sac.invoke(jsns_builder.to_delete)
        @id = nil
      end

      def modify!
        sac.invoke(jsns_builder.to_update)
        true
      end

      def create!
        resp = sac.invoke(jsns_builder.to_create)
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

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= ResourceJsnsBuilder.new(self)
      end
    end
  end
end
