# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::MailboxObject
      def delete!
        sac.jsns_request(:DeleteCalendarResourceRequest, { id: @id })
        @id = nil
      end

      def modify!
        sac.jsns_request(:ModifyCalendarResourceRequest, jsns_builder.to_update)
        true
      end

      def create!
        rep = sac.jsns_request(:CreateCalendarResourceRequest, jsns_builder.to_jsns)
        @id = rep[:Body][:CreateCalendarResourceResponse][:calresource].first[:id]
      end

      def attrs_write
        @parent.zimbra_attributes.all_resource_attrs_writable_names
      end

      private

      def do_update!(hash)
        sac.jsns_request(:ModifyCalendarResourceRequest, jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= ResourceJsnsBuilder.new(self)
      end
    end
  end
end
