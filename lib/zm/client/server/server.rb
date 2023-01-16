# frozen_string_literal: true

require 'zm/client/backup'
require 'zm/client/mta_queue'

module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::AdminObject
      def mta_queues
        @mta_queues ||= mta_queues!
      end

      def mta_queues!
        MtaQueuesCollection.new self
      end

      def backups
        @backups ||= backups!
      end

      def backups!
        BackupsCollection.new self
      end

      def accounts
        @accounts ||= ServerAccountsCollection.new(self)
      end
    end
  end
end
