# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraCalendarResource
    class Resource < Base::MailboxObject
      def delete!
        sac.delete_resource(@id)
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        sac.modify_resource(jsns_builder.to_patch(hash))

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def modify!
        sac.modify_resource(jsns_builder.to_update)
        true
      end

      def create!
        rep = sac.create_resource(jsns_builder.to_jsns)
        @id = rep[:Body][:CreateCalendarResourceResponse][:calresource].first[:id]
      end

      def attrs_write
        @parent.zimbra_attributes.all_resource_attrs_writable_names
      end

      private

      def jsns_builder
        @jsns_builder ||= ResourceJsnsBuilder.new(self)
      end
    end
  end
end
