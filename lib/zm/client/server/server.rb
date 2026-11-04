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

      private

      def do_update!(hash)
        soap_request = SoapRequest::SoapElement.admin(SoapRequest::SoapAdminConstants::MODIFY_SERVER_REQUEST)
        soap_request.add_node(SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ID).add_content(@id))

        hash.each do |key, values|
          values = [values] unless values.is_a?(Array)
          values.each { |value| soap_request.add_node(attr_node(key, value)) }
        end

        sac.invoke(soap_request)
      end

      def attr_node(key, value)
        SoapRequest::SoapElement.create(SoapRequest::SoapConstants::A)
                                .add_attribute(SoapRequest::SoapConstants::N, key)
                                .add_content(value)
      end
    end
  end
end
