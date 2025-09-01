# frozen_string_literal: true

require_relative 'mailbox_item_id'

module Zm
  module Client
    module MailboxItemConcern
      def id=(remote_id)
        parts = remote_id.split(':').reverse
        parts << nil if parts.length == 1
        @id = MailboxItemID.new(*parts)
      end

      def id
        @id.item_id
      end

      def mailbox_id
        @id.mailbox_id
      end
    end
  end
end
