# frozen_string_literal: true

require 'zm/modules/common/account_common'
# require_relative '../../modules/common/account_galsync'
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

      def to_h
        hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def all_instance_variable_keys
        AccountCommon::ZM_ACCOUNT_ATTRS
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

      def data_sources
        @data_sources ||= DataSourcesCollection.new sac, self
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

      def delete!
        sac.delete_account(@id)
      end

      def update!(hash)
        sac.modify_account(@id, hash)

        hash.each do |k, v|
          arrow_attr_sym = "@#{k}".to_sym

          if v.respond_to?(:empty?) && v.empty?
            self.remove_instance_variable(arrow_attr_sym) if self.instance_variable_get(arrow_attr_sym)
          else
            self.instance_variable_set(arrow_attr_sym, v)
          end
        end
      end

      def modify!
        attrs_to_modify = instance_variables_array(attrs_write)
        return if attrs_to_modify.empty?

        sac.modify_account(@id, attrs_to_modify)
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
        @aliases ||= set_aliases
      end

      def set_aliases
        return [] if zimbraMailAlias.nil?
        return [zimbraMailAlias] if zimbraMailAlias.is_a?(String)
        zimbraMailAlias
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

      def created_at
        @created_at ||= Time.parse zimbraCreateTimestamp unless zimbraCreateTimestamp.nil?
      end

      def flush_cache!
        sac.flush_cache('account', 1, @id)
      end

      def move_mailbox(server)
        raise Zm::Client::SoapError, 'zimbraMailHost is null' if zimbraMailHost.nil?

        sac.move_mailbox(@name, zimbraMailHost, server.name, server.id)
      end

      def is_on_to_move?(server)
        resp = sac.query_mailbox_move(@name, server.id)
        resp[:Body][:QueryMailboxMoveResponse][:account].nil?
      end

      def init_from_json(json)
        @used = json[:used] if json[:used]
        @zimbraMailQuota = json[:limit] if json[:limit]
        super(json)
      end
    end
  end
end
