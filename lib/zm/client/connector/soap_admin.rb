# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAdminConnector < SoapBaseConnector
      ADMINSPACE = 'urn:zimbraAdmin'
      A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }

      attr_accessor :token

      def initialize(scheme, host, port)
        super(scheme, host, port, '/service/admin/soap/')
      end

      def auth(mail, password)
        body = { Body: { AuthRequest: { _jsns: ADMINSPACE, name: mail, password: password } } }
        res = curl_request(body, AuthError)
        @token = res[:Body][:AuthResponse][:authToken][0][:_content]
      end

      # def noop
      #   body = init_hash_request(:NoOpRequest)
      #   curl_request(body)
      # end

      def delegate_auth(name, by = :name, duration = nil)
        req = { duration: duration, account: { by: by, _content: name } }.reject { |_, v| v.nil? }
        body = init_hash_request(:DelegateAuthRequest)
        body[:Body][:DelegateAuthRequest].merge!(req)
        res = curl_request(body)
        res[:Body][:DelegateAuthResponse][:authToken][0][:_content]
      end

      # def get_license
      #   body = init_hash_request(:GetLicenseRequest)
      #   curl_request(body)
      # end

      # def count_object(type)
      #   soap_name = :CountObjectsRequest
      #   body = init_hash_request(soap_name)
      #   req = { type: type }
      #   body[:Body][soap_name].merge!(req)
      #   curl_request(body)
      # end

      # def create_gal_sync_account(name, domain_name, type, server_name, folder_name, account_name, attrs = {})
      #   req = {
      #     name: name,
      #     domain: domain_name,
      #     type: type,
      #     server: server_name,
      #     folder: folder_name,
      #     account: { by: :name, _content: account_name },
      #     a: attrs.to_a.map(&A_NODE_PROC)
      #   }.reject { |_, v| v.nil? }
      #
      #   body = init_hash_request(:CreateGalSyncAccountRequest)
      #   body[:Body][:CreateGalSyncAccountRequest].merge!(req)
      #
      #   curl_request(body)
      # end

      # def sync_gal_account(gal_account_id, data_source, by = :name, full_sync = 1, reset = 1)
      #   req = {
      #     account: {
      #       id: gal_account_id,
      #       datasource: {
      #         by: by,
      #         fullSync: full_sync,
      #         reset: reset,
      #         _content: data_source
      #       }
      #     }
      #   }
      #   body = init_hash_request(:SyncGalAccountRequest)
      #   body[:Body][:SyncGalAccountRequest].merge!(req)
      #   curl_request(body)
      # end

      # def get_all_domains
      #   body = init_hash_request(:GetAllDomainsRequest)
      #   curl_request(body)
      # end

      # def create_data_source(name, account_id, type, attrs = {})
      #   req = {
      #     id: account_id,
      #     dataSource: {
      #       type: type,
      #       name: name,
      #       a: attrs.to_a.map(&A_NODE_PROC)
      #     }
      #   }
      #   body = init_hash_request(:CreateDataSourceRequest)
      #   body[:Body][:CreateDataSourceRequest].merge!(req)
      #   curl_request(body)
      # end

      # def get_data_sources(id)
      #   req = { id: id }
      #   body = init_hash_request(:GetDataSourcesRequest)
      #   body[:Body][:GetDataSourcesRequest].merge!(req)
      #   curl_request(body)
      # end

      # def delete_data_source(account_id, data_source_id)
      #   req = { id: account_id, dataSource: { id: data_source_id } }
      #   body = init_hash_request(:DeleteDataSourceRequest)
      #   body[:Body][:DeleteDataSourceRequest].merge!(req)
      #   curl_request(body)
      # end

      # def get_all_servers(services = nil)
      #   req = { service: services }.reject { |_, v| v.nil? }
      #   body = init_hash_request(:GetAllServersRequest)
      #   body[:Body][:GetAllServersRequest].merge!(req)
      #   curl_request(body)
      # end

      def get_server(name, by = :name, attrs = nil)
        req = { server: { by: by, _content: name }, attrs: attrs }
        body = init_hash_request(:GetServerRequest)
        body[:Body][:GetServerRequest].merge!(req)
        curl_request(body)
      end

      def get_cos(name, by = :name, attrs = nil)
        req = { cos: { by: by, _content: name } }
        req[:attrs] = attrs unless attrs.nil? || attrs.empty?
        body = init_hash_request(:GetCosRequest)
        body[:Body][:GetCosRequest].merge!(req)
        curl_request(body)
      end

      # def create_cos(jsns)
      #   jsns_request(:CreateCosRequest, jsns)
      # end

      # def modify_cos(jsns)
      #   jsns_request(:ModifyCosRequest, jsns)
      # end

      def jsns_request(soap_name, jsns)
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(jsns) if jsns.is_a?(Hash)
        curl_request(body)
      end

      # def create_account(jsns)
      #   jsns_request(:CreateAccountRequest, jsns)
      # end

      # def create_resource(jsns)
      #   jsns_request(:CreateCalendarResourceRequest, jsns)
      # end

      # def create_distribution_list(jsns)
      #   jsns_request(:CreateDistributionListRequest, jsns)
      # end

      # def modify_account(jsns)
      #   jsns_request(:ModifyAccountRequest, jsns)
      # end

      # def modify_resource(jsns)
      #   jsns_request(:ModifyCalendarResourceRequest, jsns)
      # end

      # def modify_distribution_list(jsns)
      #   jsns_request(:ModifyDistributionListRequest, jsns)
      # end

      def generic_modify(soap_name, id, attrs)
        req = {
          id: id,
          a: attrs.map(&A_NODE_PROC)
        }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def add_account_alias(id, email)
        generic_alias(:AddAccountAliasRequest, id, email)
      end

      def remove_account_alias(id, email)
        generic_alias(:RemoveAccountAliasRequest, id, email)
      end

      def rename_account(id, email)
        generic_rename(:RenameAccountRequest, id, email)
      end

      def add_distribution_list_members(id, emails)
        generic_members(:AddDistributionListMemberRequest, id, emails)
      end

      def remove_distribution_list_members(id, emails)
        generic_members(:RemoveDistributionListMemberRequest, id, emails)
      end

      def generic_members(soap_name, id, emails)
        req = { id: id, dlm: emails.map { |email| { _content: email } } }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def add_distribution_list_alias(id, email)
        generic_alias(:AddDistributionListAliasRequest, id, email)
      end

      def remove_distribution_list_alias(id, email)
        generic_alias(:RemoveDistributionListAliasRequest, id, email)
      end

      def generic_alias(soap_name, id, email)
        req = { id: id, alias: email }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def rename_distribution_list(id, email)
        generic_rename(:RenameDistributionListRequest, id, email)
      end

      def generic_rename(soap_name, id, email)
        req = { id: id, newName: email }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_domain(name, by = :name, attrs = nil)
        req = { domain: { by: by, _content: name } }
        req[:attrs] = attrs unless attrs.nil?
        body = init_hash_request(:GetDomainRequest)
        body[:Body][:GetDomainRequest].merge!(req)
        curl_request(body)
      end

      # def create_domain(jsns)
      #   jsns_request(:CreateDomainRequest, jsns)
      # end

      # def modify_domain(jsns)
      #   jsns_request(:ModifyDomainRequest, jsns)
      # end

      def get_account(name, by = :name, attrs = nil, applyCos = 1)
        soap_name = :GetAccountRequest
        req = { account: { by: by, _content: name }, applyCos: applyCos }
        req[:attrs] = attrs unless attrs.nil? || attrs.empty?
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_account_membership(name, by = :name)
        soap_name = :GetAccountMembershipRequest
        req = { account: { by: by, _content: name } }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_resource(name, by = :name, attrs = nil)
        soap_name = :GetCalendarResourceRequest
        req = { calresource: { by: by, _content: name } }
        req[:attrs] = attrs unless attrs.nil?
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_distribution_list(name, by = :name, attrs = nil)
        soap_name = :GetDistributionListRequest
        req = { dl: { by: by, _content: name } }
        req[:attrs] = attrs unless attrs.nil?
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_distribution_list_membership(by_key, by = 'name', limit = nil, offset = nil)
        soap_name = :GetDistributionListMembershipRequest
        req = { dl: { by: by, _content: by_key }, limit: limit, offset: offset }
        req.reject! { |_, v| v.nil? }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)

        curl_request(body)
      end

      # def delete_account(id)
      #   generic_delete(:DeleteAccountRequest, id)
      # end

      # def delete_domain(id)
      #   generic_delete(:DeleteDomainRequest, id)
      # end

      # def delete_resource(id)
      #   generic_delete(:DeleteCalendarResourceRequest, id)
      # end

      # def delete_distribution_list(id)
      #   generic_delete(:DeleteDistributionListRequest, id)
      # end

      def distribution_list_action(name, by = :name, action = {})
        soap_name = :DistributionListActionRequest
        req = { dl: { by: by, _content: name }, action: action }
        body = init_hash_request(soap_name)
        body[:Body][soap_name][:_jsns] = Zm::Client::SoapAccountConnector::ACCOUNTSPACE
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      # def generic_delete(soap_name, id)
      #   body = init_hash_request(soap_name)
      #   body[:Body][soap_name][:id] = id
      #   curl_request(body)
      # end

      # def search_directory(jsns)
      #   soap_name = :SearchDirectoryRequest
      #   body = init_hash_request(soap_name)
      #   body[:Body][soap_name].merge!(jsns)
      #
      #   curl_request(body)
      # end

      def get_quota_usage(domain = nil, allServers = nil, limit = nil, offset = nil, sortBy = nil, sortAscending = nil,
                          refresh = nil, target_server_id = nil)
        soap_name = :GetQuotaUsageRequest
        req = {
          domain: domain,
          allServers: allServers,
          limit: limit,
          offset: offset,
          sortBy: sortBy,
          sortAscending: sortAscending,
          refresh: refresh
        }.reject { |_, v| v.nil? }

        body = init_hash_request(soap_name, target_server_id)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_mailbox(id)
        soap_name = :GetMailboxRequest
        req = {
          mbox: {
            id: id
          }
        }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def flush_cache(type, all_servers, id = nil, target_server_id = nil)
        soap_name = :FlushCacheRequest
        req = { cache: { type: type, allServers: all_servers } }
        req[:cache].merge!({ entry: { by: :id, _content: id } }) unless id.nil?
        body = init_hash_request(soap_name, target_server_id)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_share_info(id)
        soap_name = :GetShareInfoRequest
        req = { owner: { by: :id, _content: id } }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def move_mailbox(name, src, dest, dest_id)
        soap_name = :MoveMailboxRequest
        req = { account: { name: name, dest: dest, src: src } }
        body = init_hash_request(soap_name, dest_id)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def query_mailbox_move(name, dest_id)
        soap_name = :QueryMailboxMoveRequest
        req = { account: { name: name } }
        body = init_hash_request(soap_name, dest_id)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_mail_queue_info(server_name)
        soap_name = :GetMailQueueInfoRequest
        body = init_hash_request(soap_name)
        req = { server: { name: server_name } }
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def backup_query(dest_id)
        soap_name = :BackupQueryRequest
        body = init_hash_request(soap_name, dest_id)
        req = { query: {} }
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      # def set_password(id, new_password)
      #   soap_name = :SetPasswordRequest
      #   body = init_hash_request(soap_name)
      #   req = { id: id, newPassword: new_password }
      #   body[:Body][soap_name].merge!(req)
      #   curl_request(body)
      # end

      # def get_version_info
      #   soap_name = :GetVersionInfoRequest
      #   body = init_hash_request(soap_name)
      #   curl_request(body)
      # end

      def init_hash_request(soap_name, target_server = nil)
        {
          Body: {
            soap_name => { _jsns: ADMINSPACE }
          }
        }.merge(hash_header(@token, target_server))
      end
    end
  end
end
