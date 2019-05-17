require 'json'
require 'openssl'
require 'curb'
require 'uri'

require_relative 'soap_error'

module Zm
  module Client
    class SoapBaseConnector
      BASESPACE = 'urn:zimbra'.freeze
      HTTP_HEADERS = {
        'Content-Type' => 'application/json; charset=utf-8'
      }.freeze
      BODY = :Body

      private

      def init_curl_client
        @curl = ::Curl::Easy.new(@uri.to_s) do |curl|
          curl.timeout = 7200
          curl.enable_cookies = false
          curl.encoding = ''
          curl.headers = HTTP_HEADERS
          curl.ssl_verify_peer = false
          curl.verbose = false
        end
      end

      def curl_request(body, error_handler = SoapError)
        @curl.http_post(body.to_json)

        soapbody = JSON.parse(@curl.body_str, symbolize_names: true)
        raise(error_handler, soapbody) if @curl.status.to_i >= 400

        soapbody
      end

      def curl_xml(xml, error_handler = SoapError)
        @curl.http_post(xml)

        soapbody = JSON.parse(@curl.body_str, symbolize_names: true)
        raise(error_handler, soapbody) if @curl.status.to_i >= 400

        soapbody
      end

      def hash_header(token)
        { Header: { context: { authToken: token }, _jsns: BASESPACE } }
      end
    end
  end
end
