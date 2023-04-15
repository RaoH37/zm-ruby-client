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

      def initialize(scheme, host, port)
        super(scheme, host, port, '/service/soap/')
      end

      def auth_preauth(content, by, expires, domainkey)
        ts = (Time.now.to_i * 1000)
        preauth = compute_preauth(content, by, ts, expires, domainkey)

        jsns = {
          account: {
            _content: content,
            by: by
          },
          preauth: {
            _content: preauth,
            timestamp: ts
          }
        }

        do_auth(jsns)
      end

      def auth_password(content, by, password)
        jsns = {
          account: {
            _content: content,
            by: by
          },
          password: password
        }

        do_auth(jsns)
      end

      def do_auth(jsns)
        res = jsns_request(:AuthRequest, nil, jsns, ACCOUNTSPACE, AuthError)
        res[:Body][:AuthResponse][:authToken].first[:_content]
      end

      # -------------------------------
      # GENERIC

      def jsns_request(soap_name, token, jsns, namespace = MAILSPACE, error_handler = SoapError)
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
