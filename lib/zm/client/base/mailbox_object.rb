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

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AdminObject
      class MailboxObject < AdminObject
        attr_accessor :home_url, :password, :carLicense
        attr_writer :used, :domain_key

        def initialize(parent)
          super(parent)
          @grantee_type = 'usr'
        end

        def rest_account_connector
          @rest_account_connector ||= RestAccountConnector.new
        end

        alias rac rest_account_connector

        def domain_name
          @domain_name ||= @name.split('@').last
        end

        def infos
          @infos || read_infos
        end

        def read_infos
          @infos = sacc.get_info(@token)[:Body][:GetInfoResponse]
          @id = @infos[:id]
          @used = @infos[:used]
          @public_url = @infos[:publicURL]
          @zimbraCOSId = @infos[:cos][:id]
          @home_url = @infos[:rest]
          @infos
        end

        def used
          @used ||= sac.get_mailbox(id)[:Body][:GetMailboxResponse][:mbox].first[:s]
        end

        def public_url
          infos if @infos.nil?
          @public_url
        end

        def home_url
          infos if @infos.nil?
          @home_url
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

        def account_login_preauth
          raise ZmError, 'domain key is required to login !' if domain_key.nil?

          @token = sacc.auth_preauth(@name, domain_key)
        end

        def account_login_password
          raise ZmError, 'password is required to login !' if password.nil?

          @token = sacc.auth_password(@name, @password)
        end

        def admin_login
          @token = sac.delegate_auth(@name)
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

        def message_folders
          @message_folders ||= folders.all.select { |f| f.view == Zm::Client::FolderView::MESSAGE.to_s }
        end

        def contact_folders
          @contact_folders ||= folders.all.select { |f| f.view == Zm::Client::FolderView::CONTACT.to_s }
        end

        def calendar_folders
          @calendar_folders ||= folders.all.select { |f| f.view == Zm::Client::FolderView::APPOINTMENT.to_s }
        end

        def task_folders
          @task_folders ||= folders.all.select { |f| f.view == Zm::Client::FolderView::TASK.to_s }
        end

        def document_folders
          @document_folders ||= folders.all.select { |f| f.view == Zm::Client::FolderView::DOCUMENT.to_s }
        end

        def memberships
          @memberships ||= AccountDlsMembershipCollection.new(self)
        end

        def dls_owner
          @dls_owner ||= AccountDlsOwnerCollection.new(self)
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
          sac.rename_account(@id, email)
          @name = email
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
