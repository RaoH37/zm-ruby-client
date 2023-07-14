# frozen_string_literal: true

module Zm
  module Client
    # class for account folder jsns builder
    class FolderJsnsBuilder < BaseAccountJsnsBuilder
      def to_find
        attrs = { folder: { l: @item.id } }
        SoapElement.mail(SoapMailConstants::GET_FOLDER_REQUEST).add_attributes(attrs)
      end

      def to_jsns
        folder = {
          f: @item.f,
          name: @item.name,
          l: @item.l,
          color: @item.color,
          rgb: @item.rgb,
          url: @item.url,
          fb: @item.fb,
          view: @item.view
        }.delete_if { |_, v| v.nil? }

        attrs = { folder: folder }

        SoapElement.mail(SoapMailConstants::CREATE_FOLDER_REQUEST).add_attributes(attrs)
      end

      alias to_create to_jsns

      def to_update
        action = {
          op: :update,
          id: @item.id,
          f: @item.f,
          name: @item.name,
          l: @item.l,
          color: @item.color,
          rgb: @item.rgb,
          url: @item.url,
          fb: @item.fb,
          view: @item.view
        }.delete_if { |_, v| v.nil? }

        if @item.is_immutable?
          action.delete(:name)
          action.delete(:l)
        end

        attrs = { action: action }

        SoapElement.mail(SoapMailConstants::FOLDER_ACTION_REQUEST).add_attributes(attrs)
      end

      def to_patch(options)
        action = {
          op: :update,
          id: @item.id
        }.merge(options)

        attrs = { action: action }

        SoapElement.mail(SoapMailConstants::FOLDER_ACTION_REQUEST).add_attributes(attrs)
      end

      def to_retentionpolicy
        retentionpolicy = @item.retention_policies.all.map { |rp| retentionpolicy_jsns(rp) }.reduce({}, :merge)

        {
          action: {
            op: :retentionpolicy,
            id: @item.id,
            retentionPolicy: retentionpolicy
          }
        }
      end

      private

      def retentionpolicy_jsns(rp)
        {
          rp.policy => {
            policy: {
              lifetime: rp.lifetime,
              type: rp.type
            }
          }
        }
      end
    end
  end
end
