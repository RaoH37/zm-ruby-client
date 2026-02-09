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
