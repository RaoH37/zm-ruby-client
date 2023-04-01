# frozen_string_literal: true

module Zm
  module Client
    # class for account identity jsns builder
    class IdentityJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_jsns
        hash = {
          zimbraPrefIdentityName: @item.zimbraPrefIdentityName,
          zimbraPrefFromDisplay: @item.zimbraPrefFromDisplay,
          zimbraPrefFromAddress: @item.zimbraPrefFromAddress,
          zimbraPrefFromAddressType: @item.zimbraPrefFromAddressType,
          zimbraPrefReplyToEnabled: @item.zimbraPrefReplyToEnabled,
          zimbraPrefReplyToDisplay: @item.zimbraPrefReplyToDisplay,
          zimbraPrefReplyToAddress: @item.zimbraPrefReplyToAddress,
          zimbraPrefDefaultSignatureId: @item.zimbraPrefDefaultSignatureId,
          zimbraPrefForwardReplySignatureId: @item.zimbraPrefForwardReplySignatureId,
          zimbraPrefWhenSentToEnabled: @item.zimbraPrefWhenSentToEnabled,
          zimbraPrefWhenInFoldersEnabled: @item.zimbraPrefWhenInFoldersEnabled,
          zimbraPrefWhenSentToAddresses: @item.zimbraPrefWhenSentToAddresses
        }

        jsns = to_patch(hash)

        jsns[:identity][:id] = @item.id unless @item.id.nil?

        jsns
      end

      def to_patch(hash)
        {
          identity: {
            _attrs: hash
          }
        }
      end

      def to_delete
        { identity: { id: @item.id } }
      end
    end
  end
end
