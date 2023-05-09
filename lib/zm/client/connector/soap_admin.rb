# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAdminConnector < SoapBaseConnector
      ADMINSPACE = 'urn:zimbraAdmin'
      A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }

      class << self
        def create(config)
          trans = new(
            config.zimbra_admin_scheme,
            config.zimbra_admin_host,
            config.zimbra_admin_port
          )
          trans.logger = config.logger
          trans
        end
      end

      # attr_accessor :token
      def token
        context.to_hash[:authToken]
      end

      def token=(value)
        context.token(value)
      end

      def initialize(scheme, host, port)
        super(scheme, host, port, SoapAdminConstants::ADMIN_SERVICE_URI)
      end

      def jsns_request(soap_name, jsns)
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(jsns) if jsns.is_a?(Hash)
        curl_request(body)
      end

      def generic_modify(soap_name, id, attrs)
        req = {
          id: id,
          a: attrs.map(&A_NODE_PROC)
        }
        body = init_hash_request(soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def distribution_list_action(name, by = :name, action = {})
        soap_name = :DistributionListActionRequest
        req = { dl: { by: by, _content: name }, action: action }
        body = init_hash_request(soap_name)
        body[:Body][soap_name][:_jsns] = Zm::Client::SoapAccountConnector::ACCOUNTSPACE
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

      def init_hash_request(soap_name, target_server = nil)
        {
          Body: {
            soap_name => { _jsns: ADMINSPACE }
          }
        }.merge(hash_header(token, target_server))
      end
    end
  end
end
