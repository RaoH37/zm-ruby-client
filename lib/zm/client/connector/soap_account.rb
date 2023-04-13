# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAccountConnector < SoapBaseConnector
      MAILSPACE = 'urn:zimbraMail'
      ACCOUNTSPACE = 'urn:zimbraAccount'
      # A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }

      def initialize(scheme, host, port)
        super(scheme, host, port, '/service/soap/')
      end

      def auth_preauth(mail, domainkey)
        ts = (Time.now.to_i * 1000)
        preauth = compute_preauth(mail, ts, domainkey)
        body = auth_template(mail)
        preauth_h = {
          preauth: {
            _content: preauth,
            timestamp: ts
          }
        }
        body[:Body][:AuthRequest].merge!(preauth_h)
        do_auth(body)
      end

      def auth_password(mail, password)
        body = auth_template(mail)
        body[:Body][:AuthRequest].merge!({ password: password })
        do_auth(body)
      end

      def do_auth(body)
        res = curl_request(body, AuthError)
        res[:Body][:AuthResponse][:authToken].first[:_content]
      end

      # -------------------------------
      # GENERIC

      def jsns_request(soap_name, token, jsns, namespace = MAILSPACE)
        body = init_hash_request(token, soap_name, namespace)
        body[:Body][soap_name].merge!(jsns) if jsns.is_a?(Hash)
        curl_request(body)
      end

      private

      def auth_template(mail)
        {
         Body: {
          AuthRequest: {
           _jsns: ACCOUNTSPACE,
           account: {
            _content: mail,
            by: :name
           }
          }
         }
        }
      end

      def compute_preauth(mail, ts, domainkey)
        data = "#{mail}|name|0|#{ts}"
        digest = OpenSSL::Digest.new('sha1')
        hmac = OpenSSL::HMAC.hexdigest(digest, domainkey, data)
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
