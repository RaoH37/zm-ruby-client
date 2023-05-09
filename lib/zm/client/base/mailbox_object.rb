# frozen_string_literal: true

require 'zm/client/connector/rest_account'
require 'zm/client/signature'
require 'zm/client/folder'
require 'zm/client/mountpoint'
require 'zm/client/search_folder'
require 'zm/client/share'
require 'zm/client/tag'
require 'zm/client/ace'
require 'zm/client/contact'
require 'zm/client/appointment'
require 'zm/client/task'
require 'zm/client/document'
require 'zm/client/message'
require 'zm/client/identity'
require 'zm/client/upload'
require 'zm/client/filter_rule'

module Zm
  module Client
    module Base
      # Abstract Class for Account and Resource
      class MailboxObject < Object
        include HasSoapAdminConnector

        attr_accessor :home_url, :public_url, :password, :carLicense
        attr_writer :used, :domain_key

        def soap_account_connector
          @soap_account_connector ||= SoapAccountConnector.create(@parent.config)
        end
        alias sacc soap_account_connector

        def rest_account_connector
          @rest_account_connector ||= RestAccountConnector.new
        end

        alias rac rest_account_connector

        def domain_name
          @domain_name ||= @name.split('@').last
        end

        def infos
          @infos ||= MailboxInfosCollection.new(self)
        end

        def prefs
          @prefs ||= MailboxPrefsCollection.new(self)
        end

        def used
          @used || used!
        end

        def used!
          @used = mailbox_infos[:s]
        end

        def mbxid
          @mbxid || mbxid!
        end

        def mbxid!
          @mbxid = mailbox_infos[:mbxid]
        end

        def mailbox_infos
          soap_request = SoapElement.admin(SoapAdminConstants::GET_MAILBOX_REQUEST)
          node_mbox = SoapElement.create('mbox').add_attribute('id', @id)
          soap_request.add_node(node_mbox)
          sac.invoke(soap_request)[:GetMailboxResponse][:mbox].first
        end

        # #################################################################
        # Authentication
        # #################################################################

        def logged?
          !@token.nil?
        end

        def domain_key
          @domain_key ||= @parent.domain_key(domain_name)
        end

        def login
          if @parent.logged?
            admin_login
          else
            account_login
          end
        end

        def account_login
          if password
            account_login_password
          else
            account_login_preauth
          end
        end

        def account_login_preauth(expires = 0)
          raise ZmError, 'domain key is required to login !' if domain_key.nil?

          content, by = account_content_by

          @token = sacc.auth_preauth(content, by, expires, domain_key)
        end

        def account_login_password
          raise ZmError, 'password is required to login !' if password.nil?

          content, by = account_content_by

          @token = sacc.auth_password(content, by, @password)
        end

        def account_content_by
          @id ? [@id, :id] : [@name, :name]
        end

        def admin_login
          # @token = sac.delegate_auth(@name)

          soap_request = SoapElement.admin(SoapAdminConstants::DELEGATE_AUTH_REQUEST)
          node_account = SoapElement.create('account')

          if recorded?
            node_account.add_attribute('by', 'id').add_content(@id)
          else
            node_account.add_attribute('by', 'name').add_content(@name)
          end

          soap_request.add_node(node_account)
          @token = sac.invoke(soap_request)[:DelegateAuthResponse][:authToken].first[:_content]
        end

        # #################################################################
        # Associations
        # #################################################################

        def token_metadata
          @token_metadata ||= TokenMetaData.new(@token)
        end

        def messages
          @messages ||= MessagesCollection.new(self)
        end

        def folders
          @folders ||= FoldersCollection.new(self)
        end

        def mountpoints
          @mountpointss ||= MountPointsCollection.new(self)
        end

        def search_folders
          @search_folders ||= SearchFoldersCollection.new(self)
        end

        def identities
          @identities ||= IdentitiesCollection.new(self)
        end

        def shares
          @shares ||= SharesCollection.new(self)
        end

        def contacts
          @contacts ||= ContactsCollection.new(self)
        end

        def appointments
          @appointments ||= AppointmentsCollection.new(self)
        end

        def tags
          @tags ||= TagsCollection.new(self)
        end

        def tasks
          @tasks ||= TasksCollection.new(self)
        end

        def aces
          @aces ||= AcesCollection.new(self)
        end
        alias rights aces

        def signatures
          @signatures ||= SignaturesCollection.new(self)
        end

        def documents
          @documents ||= DocumentsCollection.new(self)
        end

        def memberships
          @memberships ||= AccountDlsMembershipCollection.new(self)
        end

        def dls_owner
          @dls_owner ||= AccountDlsOwnerCollection.new(self)
        end

        def filter_rules
          @filter_rules ||= FilterRulesCollection.new(self)
        end

        def outgoing_filter_rules
          @outgoing_filter_rules ||= OutgoingFilterRulesCollection.new(self)
        end

        # #################################################################
        # SOAP Actions
        # #################################################################

        def password!(new_password = nil)
          new_password ||= @password
          return false if new_password.nil?

          sac.jsns_request(:SetPasswordRequest, { id: @id, newPassword: new_password })
          @password = new_password
        end

        def rename!(email)
          # sac.rename_account(@id, email)

          soap_request = SoapElement.admin(SoapAdminConstants::RENAME_ACCOUNT_REQUEST)
          soap_request.add_attributes({ id: @id, newName: email })
          sac.invoke(soap_request)

          @name = email
        end

        def update!(hash)
          return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

          do_update!(hash)

          hash.each do |key, value|
            update_attribute(key, value)
          end

          true
        end

        def local_transport
          raise Zm::Client::SoapError, 'zimbraMailHost is null' if zimbraMailHost.nil?

          "lmtp:#{zimbraMailHost}:7025"
        end

        def local_transport!
          update!(zimbraMailTransport: local_transport)
        end

        def is_local_transport?
          return nil unless zimbraMailTransport

          zimbraMailTransport.start_with?('lmtp')
        end

        def is_external_transport?
          return nil unless zimbraMailTransport

          zimbraMailTransport.start_with?('smtp')
        end

        def last_logon
          @last_logon ||= Time.parse(zimbraLastLogonTimestamp) unless zimbraLastLogonTimestamp.nil?
        end

        # #################################################################

        def uploader
          @uploader ||= Upload.new(self)
        end
      end
    end
  end
end
