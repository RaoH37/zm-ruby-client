# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::Object
      extend Relationship
      include Zm::Utils::HasSoapAdminConnector

      has_many :mta_queues, klass: :'Zm::Client::MtaQueuesCollection'
      has_many :backups, klass: :'Zm::Client::BackupsCollection'
      has_many :accounts, klass: :'Zm::Client::ServerAccountsCollection'

      def update!(hash, update_attributes: true)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        do_update!(hash)

        do_update_attributes(hash) if update_attributes

        @updated = true
      end

      def do_update_attributes(hash)
        hash.each do |key, value|
          update_attribute(key, value)
        end
      end

      def mailboxes
        soap_request = Zm::SoapRequest::SoapElement.admin(SoapRequest::SoapAdminConstants::GET_ALL_MAILBOXES_REQUEST)
        @parent.soap_admin_connector.context.target_server(@id)
        @parent.soap_admin_connector.invoke(soap_request).dig(:GetAllMailboxesResponse, :mbox)
      end
    end
  end
end
