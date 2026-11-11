# frozen_string_literal: true

module Zm
  module Client
    MailboxItemID = Data.define(:item_id, :mailbox_id) do
      def self.create(remote_id)
        parts = remote_id.to_s.split(':').reverse
        parts << nil if parts.length == 1
        new(*parts)
      end
    end
  end
end
