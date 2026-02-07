# frozen_string_literal: true

require 'zm/client/mailbox/mailbox_item_concern'
require 'zm/client/connector/rest_connector'
require 'zm/client/account/account_aliases_collection'
require 'zm/client/base/mailbox_infos_collection'
require 'zm/client/base/mailbox_prefs_collection'
require 'zm/client/account/account_dls_membership_collection'
require 'zm/client/account/account_dls_owner_collection'
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
        extend Relationship

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
          elsif (@id || @name) && @parent&.logged?
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

        def domain_name
          return @domain_name if defined? @domain_name

          @domain_name = @name.split('@').last
        end

        has_many :aliases, klass: AccountAliasesCollection
        has_many :infos, klass: MailboxInfosCollection
        has_many :prefs, klass: MailboxPrefsCollection

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

        has_many :messages
        has_many :folders
        has_many :mount_points
        alias mountpoints mount_points

        has_many :search_folders
        has_many :identities
        has_many :shares
        has_many :contacts
        has_many :appointments
        has_many :tags
        has_many :tasks
        has_many :aces
        alias rights aces

        has_many :signatures
        has_many :documents
        has_many :memberships, klass: AccountDlsMembershipCollection
        has_many :dls_owner, klass: AccountDlsOwnerCollection
        has_many :filter_rules
        has_many :outgoing_filter_rules
        has_many :data_sources

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
          return false unless zimbraMailTransport

          zimbraMailTransport.start_with?(SoapConstants::LMTP)
        end

        def is_external_transport?
          return false unless zimbraMailTransport

          zimbraMailTransport.start_with?(SoapConstants::SMTP)
        end

        def last_logon
          return @last_logon if defined? @last_logon

          @last_logon = Time.parse(zimbraLastLogonTimestamp) unless zimbraLastLogonTimestamp.nil?
        end

        # #################################################################

        def build_uploader
          tmp_token = soap_connector&.token
          raise ZmError, 'token have to be set to instance Upload class' unless tmp_token

          Upload.new(rest_url, tmp_token, is_token_admin: soap_connector.is_a?(SoapAdminConnector), **rest_options)
        end

        def rest_options
          if soap_config
            {
              timeout: soap_config.timeout,
              verbose: soap_config.logger.debug?
            }
          else
            {}
          end
        end

        def rest_url
          raise ZmError, 'name attribute is requuired for REST Url' unless @name

          if logged?
            rest_account_url
          elsif parent_logged?
            rest_admin_url
          else
            raise ZmError, 'impossible to set rest_url'
          end
        end

        def rest_admin_url
          raise ZmError, 'impossible to set rest_admin_url' unless soap_config.zimbra_admin_url

          File.join(soap_config.zimbra_admin_url, 'home', @name)
        end

        def rest_account_url
          if soap_config.zimbra_public_url
            File.join(soap_config.zimbra_public_url, 'home', @name)
          elsif home_url
            home_url
          else
            raise ZmError, 'impossible to set rest_account_url'
          end
        end

        private

        def soap_config
          return @soap_config if defined? @soap_config
          return unless @parent

          if @parent.respond_to?(:config)
            @soap_config = @parent.config
          elsif @parent.respond_to?(:parent) && @parent.parent.respond_to?(:config)
            @soap_config = @parent.parent.config
          end
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
