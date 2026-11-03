# frozen_string_literal: true

module Zm
  module Client
    # objectClass: zimbraServer
    class Server < Base::Object
      extend Relationship
      include Zm::Utils::HasSoapAdminConnector
      extend Base::HasZimbraAttributes

      zimbra_attr %i[cn description zimbraNotes zimbraLocale zimbraACE zimbraServiceEnabled]

      zimbra_attr %i[zimbraId zimbraCreateTimestamp], readonly: true

      has_many :mta_queues, klass: :'Zm::Client::MtaQueuesCollection'
      has_many :backups, klass: :'Zm::Client::BackupsCollection'
      has_many :accounts, klass: :'Zm::Client::ServerAccountsCollection'

      def update!(hash = nil, update_attributes: true, force: false, **attrs)
        hash = hash.nil? ? attrs : hash.merge(attrs)
        return false if zimbra_attrs_to_update(hash, force).empty?

        do_update!(hash)

        do_update_attributes(hash) if update_attributes

        @updated = true
      end

      def do_update_attributes(hash)
        hash.each do |key, value|
          update_attribute(key, value)
          forget_zimbra_attr_change(key)
        end
      end

      def mailboxes
        soap_request = Zm::SoapRequest::SoapElement.admin(SoapRequest::SoapAdminConstants::GET_ALL_MAILBOXES_REQUEST)
        @parent.soap_admin_connector.target_invoke(soap_request, @id).dig(:GetAllMailboxesResponse, :mbox)
      end
    end
  end
end
