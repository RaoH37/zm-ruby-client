# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAccountConnector < SoapBaseConnector
      MAILSPACE = 'urn:zimbraMail'
      ACCOUNTSPACE = 'urn:zimbraAccount'

      class << self
        def create(config)
          trans = new(
            config.zimbra_public_scheme,
            config.zimbra_public_host,
            config.zimbra_public_port
          )
          trans.logger = config.logger
          trans
        end
      end

      def token
        context.to_hash[:authToken]
      end

      def token=(value)
        context.token(value)
      end

      def initialize(scheme, host, port)
        super(scheme, host, port, '/service/soap/')
      end

      def auth_preauth(content, by, expires, domainkey)
        ts = (Time.now.to_i * 1000)
        preauth = compute_preauth(content, by, ts, expires, domainkey)

        soap_request = SoapElement.account(SoapAccountConstants::AUTH_REQUEST)
        node_account = SoapElement.create('account').add_attribute('by', by).add_content(content)
        soap_request.add_node(node_account)
        node_preauth = SoapElement.create('preauth').add_attribute('timestamp', ts).add_content(preauth)
        soap_request.add_node(node_preauth)

        do_login(soap_request)
      end

      def auth_password(content, by, password)
        soap_request = SoapElement.account(SoapAccountConstants::AUTH_REQUEST)
        node_account = SoapElement.create('account').add_attribute('by', by).add_content(content)
        soap_request.add_node(node_account)
        soap_request.add_attribute('password', password)

        do_login(soap_request)
      end

      def do_login(soap_request)
        invoke(soap_request)[:AuthResponse][:authToken].first[:_content]
      end

      # -------------------------------
      # GENERIC

      def jsns_request(soap_name, token, jsns, namespace = MAILSPACE, error_handler = SoapError)
        puts jsns
        body = init_hash_request(token, soap_name, namespace)
        body[:Body][soap_name].merge!(jsns) if jsns.is_a?(Hash)
        curl_request(body, error_handler)
      end

      private

      def compute_preauth(content, by, ts, expires, domain_key)
        data = "#{content}|#{by}|#{expires}|#{ts}"
        digest = OpenSSL::Digest.new('sha1')
        hmac = OpenSSL::HMAC.hexdigest(digest, domain_key, data)
        hmac.to_s
      end

      def init_hash_request(token, soap_name, namespace = MAILSPACE)
        {
          Body: {
            soap_name => { _jsns: namespace }
          }
        }.merge(hash_header(token))
      end
    end
  end
end
