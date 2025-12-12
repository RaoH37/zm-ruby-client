# frozen_string_literal: true

require_relative 'mailbox_item_id'

module Zm
  module Client
    module MailboxItemConcern
      def id=(remote_id)
        parts = remote_id.to_s.split(':').reverse
        parts << nil if parts.length == 1
        @id = MailboxItemID.new(*parts)
      end

      def id
        return nil unless defined? @id

        @id.item_id
      end

      def mailbox_id
        return nil unless defined? @id

        @id.mailbox_id
      end

      def l=(remote_l)
        @l = remote_l.to_s.split(':').last
      end

      attr_reader :l
    end
  end
end
