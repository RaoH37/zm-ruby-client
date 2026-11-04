# frozen_string_literal: true

module Zm
  module SoapRequest
    module RequestMethodsAdmin
      def delete!
        sac.invoke(build_delete)
        @id = nil
      end

      def build_delete
        jsns_builder.to_delete
      end

      def modify!(force: false)
        return false unless force || zimbra_attrs_changed?

        sac.invoke(build_modify(force:))
        clear_zimbra_attrs_changes
        @updated = true
      end

      def build_modify(force: false)
        jsns_builder.to_update(force:)
      end

      def build_create
        jsns_builder.to_create
      end

      def update!(hash = nil, update_attributes: true, force: false, **attrs)
        hash = hash.nil? ? attrs : hash.merge(attrs)
        return false if zimbra_attrs_to_update(hash, force).empty?

        do_update!(hash)

        do_update_attributes(hash) if update_attributes

        @updated = true
      end

      def do_update_attributes(hash)
        hash.each do |key, value|
          update_attribute(key, value)
          forget_zimbra_attr_change(key)
        end
      end

      def rename!(new_name)
        sac.invoke(build_rename(new_name))
        @updated = true
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
