# frozen_string_literal: true

require 'zm/modules/common/account_common'
# require_relative '../../modules/common/account_galsync'
require 'zm/client/connector/rest_account'
require 'zm/client/signature'
require 'zm/client/folder'
require 'zm/client/search_folder'
require 'zm/client/share'
require 'zm/client/tag'
require 'zm/client/ace'
require 'zm/client/contact'
require 'zm/client/appointment'
require 'zm/client/task'
require 'zm/client/document'
# require 'zm/client/data_source'
require 'zm/client/message'
require 'zm/client/identity'
require 'zm/client/upload'
require 'addressable/uri'

module Zm
  module Client
    # objectClass: zimbraAccount
    class Account < Base::AdminObject
      attr_reader :name, :id, :token
      attr_writer :home_url
      attr_accessor :password, :domainkey, :company, :zimbraCOSId, :zimbraMailHost, :zimbraMailTransport, :carLicense

      def initialize(parent)
        extend(AccountCommon)
        super(parent)
        @grantee_type = 'usr'.freeze
      end

      def rest_account_connector
        @rest_account_connector ||= RestAccountConnector.new
      end

      alias rac rest_account_connector

      def logged?
        !@token.nil?
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
        domain_key
        raise ZmError, 'domain key is required to login !' if @domainkey.nil?

        @token = sacc.auth_preauth(@name, @domainkey)
      end

      def account_login_password
        raise ZmError, 'password is required to login !' if password.nil?

        @token = sacc.auth_password(@name, @password)
      end

      def admin_login
        @token = sac.delegate_auth(@name)
      end

      def domain_name
        @name.split('@').last
      end

      def domain_key
        @domainkey ||= @parent.domain_key(domain_name)
      end

      def infos
        @infos ||= read_infos
      end

      def read_infos
        @infos = sacc.get_info(@token)[:Body][:GetInfoResponse]
        @id = @infos[:id]
        @used = @infos[:used]
        @public_url = @infos[:publicURL]
        @zimbraCOSId = @infos[:cos][:id]
        @home_url = @infos[:rest]
      end

      def cos
        @cos ||= @parent.coses.find_by(id: zimbraCOSId)
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

      def messages
        @messages ||= MessagesCollection.new(self)
      end

      def folders
        @folders ||= FoldersCollection.new(self)
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

      def data_sources
        @data_sources ||= DataSourcesCollection.new sac, self
      end

      def documents
        @documents ||= DocumentsCollection.new(self)
      end

      def message_folders
        @message_folders ||= folders.select { |f| f.view == Zm::Client::FolderView::MESSAGE }
      end

      def contact_folders
        @contact_folders ||= folders.select { |f| f.view == Zm::Client::FolderView::CONTACT }
      end

      def calendar_folders
        @calendar_folders ||= folders.select { |f| f.view == Zm::Client::FolderView::APPOINTMENT }
      end

      def task_folders
        @task_folders ||= folders.select { |f| f.view == Zm::Client::FolderView::TASK }
      end

      def document_folders
        @document_folders ||= folders.select { |f| f.view == Zm::Client::FolderView::DOCUMENT }
      end

      def delete!
        sac.delete_account(@id)
      end

      def update!(hash)
        sac.modify_account(@id, hash)

        hash.each do |k, v|
          arrow_attr_sym = "@#{k}".to_sym

          if v.empty?
            self.remove_instance_variable(arrow_attr_sym) if self.instance_variable_get(arrow_attr_sym)
          else
            self.instance_variable_set(arrow_attr_sym, v)
          end
        end
      end

      def modify!
        sac.modify_account(
          @id,
          instance_variables_array(attrs_write)
        )
      end

      def create!
        rep = sac.create_account(
          @name,
          @password,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateAccountResponse][:account].first[:id]
      end

      def aliases
        @aliases ||= []
      end

      def add_alias!(email)
        sac.add_account_alias(@id, email)
        aliases.push(email)
      end

      def remove_alias!(email)
        sac.remove_account_alias(@id, email)
        aliases.delete(email)
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

      def uploader
        @uploader ||= Upload.new(self)
      end

      def last_logon
        @last_logon ||= Time.parse zimbraLastLogonTimestamp unless zimbraLastLogonTimestamp.nil?
      end

      # Deprecated: use uploader.download_file
      #
      # def download(folder_path, fmt, types, dest_file_path)
      #   rac.download(download_url(folder_path, fmt, types), dest_file_path)
      # end
      #
      # def download_url(folder_path, fmt, types)
      #   url_folder_path = File.join(@home_url, folder_path.to_s)
      #   uri = Addressable::URI.new
      #   uri.query_values = {
      #     fmt: fmt,
      #     types: types.join(','),
      #     emptyname: 'Vide',
      #     charset: 'UTF-8',
      #     auth: 'qp',
      #     zauthtoken: @token
      #   }
      #   url_folder_path << '?' << uri.query
      #   url_folder_path
      # end

      # Deprecated: use uploader.send_file
      #
      # def upload(folder_path, fmt, types, resolve, src_file_path)
      #   rac.upload(upload_url(folder_path, fmt, types, resolve), src_file_path)
      # end
      #
      # def upload_url(folder_path, fmt, types, resolve)
      #   url_folder_path = File.join(@home_url, folder_path.to_s)
      #   uri = Addressable::URI.new
      #   uri.query_values = {
      #       fmt: fmt,
      #       types: types.join(','),
      #       resolve: resolve,
      #       auth: 'qp',
      #       zauthtoken: @token
      #   }
      #   url_folder_path << '?' << uri.query
      #   url_folder_path
      # end

      def init_from_json(json)
        @used = json[:used] if json[:used]
        @zimbraMailQuota = json[:limit] if json[:limit]
        super(json)
      end
    end
  end
end
