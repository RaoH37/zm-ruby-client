# frozen_string_literal: true

module Zm
  module Client
    module MailboxItemConcern
      def id=(remote_id)
        @id = MailboxItemID.create(remote_id)
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
