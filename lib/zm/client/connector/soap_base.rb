# frozen_string_literal: true

require 'json'
require 'openssl'
require 'curb'
require 'uri'

require_relative 'soap_error'

module Zm
  module Client
    class SoapBaseConnector
      include ZmLogger

      BASESPACE = 'urn:zimbra'
      HTTP_HEADERS = {
        'Content-Type' => 'application/json; charset=utf-8'
      }.freeze

      attr_reader :context

      def initialize(scheme, host, port, soap_path)
        @verbose = false
        @uri = URI::HTTP.new(scheme, nil, host, port, nil, soap_path, nil, nil, nil)
        @context = SoapContext.new
        init_curl_client
      end

      def verbose!
        @verbose = true
        @curl.verbose = @verbose
      end

      def invoke(soap_element, error_handler = SoapError)
        # body = envelope(soap_element)
        # puts body
        curl_request(envelope(soap_element), error_handler)[:Body]
      end

      private

      def init_curl_client
        @curl = ::Curl::Easy.new(@uri.to_s) do |curl|
          curl.timeout = 300
          curl.enable_cookies = false
          curl.encoding = ''
          curl.headers = HTTP_HEADERS
          curl.ssl_verify_peer = false
          curl.ssl_verify_host = 0
        end
      end

      def curl_request(body, error_handler = SoapError)
        logger.debug body.to_json
        @curl.http_post(body.to_json)

        logger.debug @curl.body_str

        soapbody = JSON.parse(@curl.body_str, symbolize_names: true)
        raise(error_handler, soapbody) if @curl.status.to_i >= 400

        soapbody
      end

      def envelope(soap_element)
        {
          Body: soap_element.to_hash,
          Header: { context: context.to_hash, _jsns: BASESPACE }
        }
      end

      def hash_header(token, target_server = nil)
        h_context = { authToken: token, userAgent: { name: :zmsoap }, targetServer: target_server }.delete_if do |_, v|
          v.nil?
        end
        { Header: { context: h_context, _jsns: BASESPACE } }
      end
    end
  end
end
