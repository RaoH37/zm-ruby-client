# frozen_string_literal: true

require 'zm/client/account/account_aliases_collection'

module Zm
  module Client
    # objectClass: zimbraAccount
    class Account < Base::MailboxObject
      # #################################################################
      # Associations
      # #################################################################

      def aliases
        @aliases ||= AccountAliasesCollection.new(self)
      end

      def cos
        @cos ||= @parent.coses.find_by(id: zimbraCOSId)
      end

      # #################################################################
      # SOAP Actions
      # #################################################################

      def delete!
        sac.jsns_request(:DeleteAccountRequest, { id: @id })
        @id = nil
      end

      def modify!
        sac.jsns_request(:ModifyAccountRequest, jsns_builder.to_update)
        true
      end

      def create!
        rep = sac.jsns_request(:CreateAccountRequest, jsns_builder.to_jsns)
        @id = rep[:Body][:CreateAccountResponse][:account].first[:id]
      end

      def created_at
        @created_at ||= Time.parse(zimbraCreateTimestamp) unless zimbraCreateTimestamp.nil?
      end

      def flush_cache!
        sac.flush_cache('account', 1, @id)
      end

      def move_mailbox(server)
        raise Zm::Client::SoapError, 'zimbraMailHost is null' if zimbraMailHost.nil?

        sac.move_mailbox(@name, zimbraMailHost, server.name, server.id)
      end

      def is_on_to_move?(server)
        resp = sac.query_mailbox_move(@name, server.id)
        resp[:Body][:QueryMailboxMoveResponse][:account].nil?
      end

      def ranking(op, email = nil)
        sacc.ranking_action(@token, op, email)
      end

      def attrs_write
        @parent.zimbra_attributes.all_account_attrs_writable_names
      end

      private

      def do_update!(hash)
        sac.jsns_request(:ModifyAccountRequest, jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= AccountJsnsBuilder.new(self)
      end
    end
  end
end
