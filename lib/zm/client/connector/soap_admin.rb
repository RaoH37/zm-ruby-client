# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'
require_relative 'soap_xml_builder'

module Zm
  module Client
    class SoapAdminConnector < SoapBaseConnector

      ADMINSPACE = 'urn:zimbraAdmin'.freeze
      A_NODE_PROC = lambda { |n| { n: n.first, _content: n.last } }

      attr_accessor :token

      def initialize(scheme, host, port)
        @verbose = false
        @uri = URI::HTTP.new(scheme, nil, host, port, nil, '/service/admin/soap/', nil, nil, nil)
        init_curl_client
      end

      def auth(mail, password)
        body = { Body: { AuthRequest: { _jsns: ADMINSPACE, name: mail, password: password } } }
        res = curl_request(body, AuthError)
        @token = res[BODY][:AuthResponse][:authToken][0][:_content]
      end

      def delegate_auth(name, by = :name, duration = nil)
        req = { duration: duration, account: { by: by, _content: name } }.reject { |_, v| v.nil? }
        body = init_hash_request(:DelegateAuthRequest)
        body[:Body][:DelegateAuthRequest].merge!(req)
        res = curl_request(body)
        res[BODY][:DelegateAuthResponse][:authToken][0][:_content]
      end

      def get_license
        body = init_hash_request(:GetLicenseRequest)
        curl_request(body)
      end

      def create_gal_sync_account(name, domain_name, type, server_name, folder_name, account_name, attrs = {})
        req = {
          name: name,
          domain: domain_name,
          type: type,
          server: server_name,
          folder: folder_name,
          account: { by: :name, _content: account_name },
          a: attrs.to_a.map(&A_NODE_PROC)
          # a: attrs.to_a.map { |n| { n: n.first, _content: n.last } }
        }.reject { |_, v| v.nil? }
        body = init_hash_request(:CreateGalSyncAccountRequest)
        body[:Body][:CreateGalSyncAccountRequest].merge!(req)
        curl_request(body)
      end

      def sync_gal_account(gal_account_id, data_source, by = :name, full_sync = 1, reset = 1)
        req = {
          account: {
            id: gal_account_id,
            datasource: {
              by: by,
              fullSync: full_sync,
              reset: reset,
              _content: data_source
            }
          }
        }
        body = init_hash_request(:SyncGalAccountRequest)
        body[:Body][:SyncGalAccountRequest].merge!(req)
        curl_request(body)
      end

      def get_all_domains
        body = init_hash_request(:GetAllDomainsRequest)
        curl_request(body)
      end

      def create_data_source(name, account_id, type, attrs = { })
        req = {
          id: account_id,
          dataSource: {
            type: type,
            name: name,
            a: attrs.to_a.map(&A_NODE_PROC)
            # a: attrs.to_a.map { |n| { n: n.first, _content: n.last } }
          }
        }
        body = init_hash_request(:CreateDataSourceRequest)
        body[:Body][:CreateDataSourceRequest].merge!(req)
        curl_request(body)
      end

      def get_data_sources(id)
        req = { id: id }
        body = init_hash_request(:GetDataSourcesRequest)
        body[:Body][:GetDataSourcesRequest].merge!(req)
        curl_request(body)
      end

      def delete_data_source(account_id, data_source_id)
        req = { id: account_id, dataSource: { id: data_source_id } }
        body = init_hash_request(:DeleteDataSourceRequest)
        body[:Body][:DeleteDataSourceRequest].merge!(req)
        curl_request(body)
      end

      def get_all_servers(services = nil)
        req = { service: services }.reject { |_, v| v.nil? }
        body = init_hash_request(:GetAllServersRequest)
        body[:Body][:GetAllServersRequest].merge!(req)
        curl_request(body)
      end

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

      def create_cos(name, attrs = nil)
        req = { name: name }
        body = init_hash_request(:CreateCosRequest)
        body[:Body][:CreateCosRequest].merge!(req)
        # a: attrs.to_a.map(&A_NODE_PROC)
        # a: attrs.to_a.map { |n| { n: n.first, _content: n.last } }
        puts SoapXmlBuilder.new(body).to_xml
        # todo ne fonctionne pas !
        curl_xml(SoapXmlBuilder.new(body).to_xml)
      end

      def modify_cos(id, attrs = nil)
        # req = { _jsns: ADMINSPACE, id: id, a: attrs.to_a.map{ |n| { n: n.first, _content: n.last } } }
        req = { _jsns: ADMINSPACE, id: id }
        body = { Body: { ModifyCosRequest: req } }.merge(hash_header(@token))
        # puts body
        # todo ne fonctionne pas !
        # peut-être seul la version xml fonctionne. Il faudrait créer une fonction qui converti le json en xml
        curl_request(body)
      end

      def create_account(name, password = nil, attrs = [])
        req = { name: name, password: password }.reject { |_, v| v.nil? }
        req[:a] = attrs.map { |i| i.last.is_a?(Array) ? i.last.map{|j|[i.first, j]} : [i] }.flatten(1).map(&A_NODE_PROC)
        # req[:a] = attrs.map{|i|i.last.is_a?(Array) ? i.last.map{|j|[i.first, j]} : [i]}.flatten(1).map { |n| { n: n.first, _content: n.last } }
        body = init_hash_request(:CreateAccountRequest)
        body[:Body][:CreateAccountRequest].merge!(req)
        # puts req
        curl_request(body)
      end

      def create_resource(name, password = nil, attrs = [])
        req = { name: name, password: password }.reject { |_, v| v.nil? }
        req[:a] = attrs.map { |i| i.last.is_a?(Array) ? i.last.map{|j|[i.first, j]} : [i] }.flatten(1).map(&A_NODE_PROC)
        body = init_hash_request(:CreateCalendarResourceRequest)
        body[:Body][:CreateCalendarResourceRequest].merge!(req)
        # puts req
        curl_request(body)
      end

      def create_distribution_list(name, attrs = [])
        req = { name: name }
        req[:a] = attrs.map { |i| i.last.is_a?(Array) ? i.last.map{|j|[i.first, j]} : [i] }.flatten(1).map(&A_NODE_PROC)
        body = init_hash_request(:CreateDistributionListRequest)
        body[:Body][:CreateDistributionListRequest].merge!(req)
        # puts req
        curl_request(body)
      end

      def modify_account(id, attrs = [])
        req = {
          id: id,
          a: attrs.map(&A_NODE_PROC)
          # a: attrs.map { |n| { n: n.first, _content: n.last } }
        }
        body = init_hash_request(:ModifyAccountRequest)
        body[:Body][:ModifyAccountRequest].merge!(req)
        curl_request(body)
      end

      def modify_resource(id, attrs = [])
        req = {
          id: id,
          a: attrs.map(&A_NODE_PROC)
        }
        body = init_hash_request(:ModifyCalendarResourceRequest)
        body[:Body][:ModifyCalendarResourceRequest].merge!(req)
        curl_request(body)
      end

      def add_account_alias(id, email)
        req = { id: id, alias: email }
        body = init_hash_request(:AddAccountAliasRequest)
        body[:Body][:AddAccountAliasRequest].merge!(req)
        curl_request(body)
      end

      def remove_account_alias(id, email)
        req = { id: id, alias: email }
        body = init_hash_request(:RemoveAccountAliasRequest)
        body[:Body][:RemoveAccountAliasRequest].merge!(req)
        curl_request(body)
      end

      def rename_account(id, email)
        req = { id: id, newName: email }
        body = init_hash_request(:RenameAccountRequest)
        body[:Body][:RenameAccountRequest].merge!(req)
        curl_request(body)
      end

      def add_distribution_list_members(id, emails)
        req = { id: id, dlm: emails.map { |email| {_content: email} } }
        body = init_hash_request(:AddDistributionListMemberRequest)
        body[:Body][:AddDistributionListMemberRequest].merge!(req)
        curl_request(body)
      end

      def remove_distribution_list_members(id, emails)
        req = { id: id, dlm: emails }
        body = init_hash_request(:RemoveDistributionListMemberRequest)
        body[:Body][:RemoveDistributionListMemberRequest].merge!(req)
        curl_request(body)
      end

      def add_distribution_list_alias(id, email)
        key = :AddDistributionListAliasRequest
        req = { id: id, alias: email }
        body = init_hash_request(key)
        body[:Body][key].merge!(req)
        curl_request(body)
      end

      def remove_distribution_list_alias(id, email)
        key = :RemoveDistributionListAliasRequest
        req = { id: id, alias: email }
        body = init_hash_request(key)
        body[:Body][key].merge!(req)
        curl_request(body)
      end

      def rename_distribution_list(id, email)
        key = :RenameDistributionListRequest
        req = { id: id, newName: email }
        body = init_hash_request(key)
        body[:Body][key].merge!(req)
        curl_request(body)
      end

      def get_domain(name, by = :name, attrs = nil)
        req = { domain: { by: by, _content: name } }
        req[:_attrs] = attrs unless attrs.nil?
        body = init_hash_request(:GetDomainRequest)
        body[:Body][:GetDomainRequest].merge!(req)
        # TODO: tester param attrs
        # puts body
        curl_request(body)
      end

      def get_account(name, by = :name, attrs = nil)
        req = { account: { by: by, _content: name } }
        req[:_attrs] = attrs unless attrs.nil?
        body = init_hash_request(:GetAccountRequest)
        body[:Body][:GetAccountRequest].merge!(req)
        # p body
        curl_request(body)
      end

      def get_resource(name, by = :name, attrs = nil)
        req = { account: { by: by, _content: name } }
        req[:_attrs] = attrs unless attrs.nil?
        body = init_hash_request(:GetCalendarResourceRequest)
        body[:Body][:GetCalendarResourceRequest].merge!(req)
        # p body
        curl_request(body)
      end

      def get_distribution_list(name, by = :name, attrs = nil)
        req = { dl: { by: by, _content: name } }
        req[:_attrs] = attrs unless attrs.nil?
        body = init_hash_request(:GetDistributionListRequest)
        body[:Body][:GetDistributionListRequest].merge!(req)
        # p body
        curl_request(body)
      end

      def delete_account(id)
        body = init_hash_request(:DeleteAccountRequest)
        body[:Body][:DeleteAccountRequest][:id] = id
        curl_request(body)
      end

      def delete_resource(id)
        body = init_hash_request(:DeleteCalendarResourceRequest)
        body[:Body][:DeleteCalendarResourceRequest][:id] = id
        curl_request(body)
      end

      def search_directory(query = nil, maxResults = nil, limit = nil, offset = nil, domain = nil, applyCos = nil, applyConfig = nil, sortBy = nil, types = nil, sortAscending = nil, countOnly = nil, attrs = nil)

        # Désactivé car moins performant !
        # req = Hash[method(__method__).parameters.map{ |p|[p.last, (eval p.last.to_s)] }].select!{ |k,v|!v.nil? }

        req = {
          query: query,
          maxResults: maxResults,
          limit: limit,
          offset: offset,
          domain: domain,
          applyCos: applyCos,
          applyConfig: applyConfig,
          sortBy: sortBy,
          types: types,
          sortAscending: sortAscending,
          countOnly: countOnly,
          attrs: attrs
        }.reject { |_, v| v.nil? }

        # body = { Body: { SearchDirectoryRequest: { _jsns: ADMINSPACE } } }.merge(hash_header(@token))
        body = init_hash_request(:SearchDirectoryRequest)
        body[:Body][:SearchDirectoryRequest].merge!(req)
        # puts body

        curl_request(body)
      end

      def get_quota_usage(domain = nil, allServers = nil, limit = nil, offset = nil, sortBy = nil, sortAscending = nil, refresh = nil)
        req = {
          domain: domain,
          allServers: allServers,
          limit: limit,
          offset: offset,
          sortBy: sortBy,
          sortAscending: sortAscending,
          refresh: refresh
        }.reject { |_, v| v.nil? }

        # body = { Body: { GetQuotaUsageRequest: { _jsns: ADMINSPACE } } }.merge(hash_header(@token))
        body = init_hash_request(:GetQuotaUsageRequest)
        body[:Body][:GetQuotaUsageRequest].merge!(req)
        curl_request(body)
      end

      def get_mailbox(id)
        req = {
            mbox: {
                id: id
            }
        }
        body = init_hash_request(:GetMailboxRequest)
        body[:Body][:GetMailboxRequest].merge!(req)
        curl_request(body)
      end

      def flush_cache(type, allServers, id)
        req = { cache: { type: type, allServers: allServers, entry: { by: :id, _content: id } } }
        body = init_hash_request(:FlushCacheRequest)
        body[:Body][:FlushCacheRequest].merge!(req)
        curl_request(body)
      end

      def init_hash_request(soap_name)
        {
          Body: {
            soap_name => { _jsns: ADMINSPACE }
          }
        }.merge(hash_header(@token))
      end
    end
  end
end
