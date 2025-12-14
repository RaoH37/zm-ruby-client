# frozen_string_literal: true

require 'zm/client/mailbox/mailbox_item_concern'
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
require 'zm/client/datasource'

module Zm
  module Client
    module Base
      # Abstract Class for Account and Resource
      class MailboxObject < Object
        include HasSoapAdminConnector

        attr_accessor :home_url, :public_url, :password, :carLicense
        attr_writer :used, :domain_key

        def soap_account_connector
          return @soap_account_connector if defined? @soap_account_connector

          @soap_account_connector = SoapAccountConnector.create(soap_config)
        end

        def soap_connector
          return @soap_connector if defined? @soap_connector

          if logged?
            @soap_connector = soap_account_connector
          elsif (@id || @name) && @parent && @parent.logged?
            @soap_connector = @parent.soap_admin_connector.clone

            if @id
              @soap_connector.context.account(:id, @id)
            else
              @soap_connector.context.account(:name, @name)
            end
          else
            raise ZmError, 'SoapConnector not defined'
          end

          @soap_connector
        end

        def rest_account_connector
          return @rest_account_connector if defined? @rest_account_connector

          @rest_account_connector = RestAccountConnector.new
        end

        alias rac rest_account_connector

        def domain_name
          return @domain_name if defined? @domain_name

          @domain_name = @name.split('@').last
        end

        def infos
          return @infos if defined? @infos

          @infos = MailboxInfosCollection.new(self)
        end

        def prefs
          return @prefs if defined? @prefs

          @prefs = MailboxPrefsCollection.new(self)
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
          node_mbox = SoapElement.create(SoapConstants::MBOX).add_attribute(SoapConstants::ID, @id)
          soap_request.add_node(node_mbox)
          sac.invoke(soap_request)[:GetMailboxResponse][:mbox].first
        end

        # #################################################################
        # Authentication
        # #################################################################

        def token
          return @token if defined? @token

          @token = (Token.new(soap_account_connector.token) if soap_account_connector.token)
        end

        def token=(value)
          @token = Token.new(soap_account_connector.token = value)
          @soap_connector = soap_account_connector
        end

        def logged?
          !token.nil? && !token.expired?
        end

        def alive?
          soap_request = SoapElement.mail(SoapMailConstants::NO_OP_REQUEST)
          soap_connector.invoke(soap_request)
          true
        rescue Zm::Client::SoapError => e
          logger.warn "Mailbox session token alive ? #{e.message}"
          false
        end

        def logged_and_alive?
          logged? && alive?
        end

        def domain_key
          return @domain_key if defined?(@domain_key)

          @parent.domain_key(domain_name)
        end

        def login
          if parent_logged?
            admin_login
          else
            account_login
          end
        end

        def account_login
          soap_account_connector.token = nil

          if password
            account_login_password
          else
            account_login_preauth
          end
        end

        def account_login_preauth(expires = 0)
          logger.info 'Get Account session token by preauth access'
          raise ZmError, 'domain key is required to login !' if domain_key.nil?

          content, by = account_content_by

          self.token = soap_account_connector.auth_preauth(content, by, expires, domain_key)
        end

        def account_login_password
          logger.info 'Get Account session token by password access'
          raise ZmError, 'password is required to login !' if password.nil?

          content, by = account_content_by

          self.token = soap_account_connector.auth_password(content, by, @password)
        end

        def account_content_by
          @id ? [@id, :id] : [@name, :name]
        end

        def admin_login
          logger.info 'Get Account session token by Delegate access'

          soap_request = SoapElement.admin(SoapAdminConstants::DELEGATE_AUTH_REQUEST)
          node_account = SoapElement.create(SoapConstants::ACCOUNT)

          if recorded?
            node_account.add_attribute(SoapConstants::BY, SoapConstants::ID).add_content(@id)
          else
            node_account.add_attribute(SoapConstants::BY, SoapConstants::NAME).add_content(@name)
          end

          soap_request.add_node(node_account)
          self.token = sac.invoke(soap_request)[:DelegateAuthResponse][:authToken].first[:_content]
        end

        # #################################################################
        # Associations
        # #################################################################

        def messages
          return @messages if defined? @messages

          @messages = MessagesCollection.new(self)
        end

        def folders
          return @folders if defined? @folders

          @folders = FoldersCollection.new(self)
        end

        def mountpoints
          return @mountpoints if defined? @mountpoints

          @mountpoints = MountPointsCollection.new(self)
        end

        def search_folders
          return @search_folders if defined? @search_folders

          @search_folders = SearchFoldersCollection.new(self)
        end

        def identities
          return @identities if defined? @identities

          @identities = IdentitiesCollection.new(self)
        end

        def shares
          return @shares if defined? @shares

          @shares = SharesCollection.new(self)
        end

        def contacts
          return @contacts if defined? @contacts

          @contacts = ContactsCollection.new(self)
        end

        def appointments
          return @appointments if defined? @appointments

          @appointments = AppointmentsCollection.new(self)
        end

        def tags
          return @tags if defined? @tags

          @tags = TagsCollection.new(self)
        end

        def tasks
          return @tasks if defined? @tasks

          @tasks = TasksCollection.new(self)
        end

        def aces
          return @aces if defined? @aces

          @aces = AcesCollection.new(self)
        end
        alias rights aces

        def signatures
          return @signatures if defined? @signatures

          @signatures = SignaturesCollection.new(self)
        end

        def documents
          return @documents if defined? @documents

          @documents = DocumentsCollection.new(self)
        end

        def memberships
          return @memberships if defined? @memberships

          @memberships = AccountDlsMembershipCollection.new(self)
        end

        def dls_owner
          return @dls_owner if defined? @dls_owner

          @dls_owner = AccountDlsOwnerCollection.new(self)
        end

        def filter_rules
          return @filter_rules if defined? @filter_rules

          @filter_rules = FilterRulesCollection.new(self)
        end

        def outgoing_filter_rules
          return @outgoing_filter_rules if defined? @outgoing_filter_rules

          @outgoing_filter_rules = OutgoingFilterRulesCollection.new(self)
        end

        def data_sources
          return @data_sources if defined? @data_sources

          @data_sources = DataSourcesCollection.new(self)
        end

        # #################################################################
        # SOAP Actions
        # #################################################################

        def password!(new_password = nil)
          new_password ||= @password
          return false if new_password.nil?

          soap_request = SoapElement.admin(SoapAdminConstants::SET_PASSWORD_REQUEST)
          soap_request.add_attributes({ id: @id, newPassword: new_password })
          sac.invoke(soap_request)

          @password = new_password
        end

        def local_transport
          raise Zm::Client::ZmError, 'zimbraMailHost is null' if zimbraMailHost.nil?

          "lmtp:#{zimbraMailHost}:7025"
        end

        def local_transport!
          update!(zimbraMailTransport: local_transport)
        end

        def is_local_transport?
          return nil unless zimbraMailTransport

          zimbraMailTransport.start_with?(SoapConstants::LMTP)
        end

        def is_external_transport?
          return nil unless zimbraMailTransport

          zimbraMailTransport.start_with?(SoapConstants::SMTP)
        end

        def last_logon
          return @last_logon if defined? @last_logon

          @last_logon = Time.parse(zimbraLastLogonTimestamp) unless zimbraLastLogonTimestamp.nil?
        end

        # #################################################################

        def uploader
          return @uploader if defined? @uploader

          @uploader = Upload.new(self)
        end

        private

        def soap_config
          return @parent.config if @parent.respond_to?(:config)
          return @parent.parent.config if @parent.respond_to?(:parent) && @parent.parent.respond_to?(:config)

          nil
        end

        def parent_logged?
          return @parent.logged? if @parent.respond_to?(:logged?)
          return @parent.parent.logged? if @parent.respond_to?(:parent) && @parent.parent.respond_to?(:logged?)

          false
        end
      end
    end
  end
end
