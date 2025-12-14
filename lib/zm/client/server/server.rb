# frozen_string_literal: true

require 'zm/client/backup'
require 'zm/client/mta_queue'

module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::Object
      include HasSoapAdminConnector

      def mta_queues
        return @mta_queues if defined? @mta_queues

        @mta_queues = MtaQueuesCollection.new(self)
      end

      def backups
        return @backups if defined? @backups

        @backups = BackupsCollection.new(self)
      end

      def accounts
        return @accounts if defined? @accounts

        @accounts = ServerAccountsCollection.new(self)
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        do_update!(hash)

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end
    end
  end
end
