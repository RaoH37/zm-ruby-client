# frozen_string_literal: true

require 'zm/client/backup'
require 'zm/client/mta_queue'

require 'zm/client/server/server_attrs'

module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::Object
      include HasSoapAdminConnector
      include ServerAttrs

      def mta_queues
        @mta_queues ||= MtaQueuesCollection.new(self)
      end

      def backups
        @backups ||= BackupsCollection.new(self)
      end

      def accounts
        @accounts ||= ServerAccountsCollection.new(self)
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
