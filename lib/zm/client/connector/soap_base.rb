# frozen_string_literal: true

require 'json'
require 'openssl'
require 'curb'
require 'uri'

require_relative 'soap_error'

module Zm
  module Client
    class SoapBaseConnector
      BASESPACE = 'urn:zimbra'
      HTTP_HEADERS = {
        'Content-Type' => 'application/json; charset=utf-8'
      }.freeze
      BODY = :Body

      def initialize(scheme, host, port, soap_path)
        extend(ZmLogger)
        @verbose = false
        @uri = URI::HTTP.new(scheme, nil, host, port, nil, soap_path, nil, nil, nil)
      end

      def verbose!
        @verbose = true
      end

      private

      def init_curl_client
        ::Curl::Easy.new(@uri.to_s) do |curl|
          curl.timeout = 300
          curl.enable_cookies = false
          curl.encoding = ''
          curl.headers = HTTP_HEADERS
          curl.ssl_verify_peer = false
          curl.ssl_verify_host = 0
          curl.verbose = @verbose
        end
      end

      def curl_request(body, error_handler = SoapError)
        curl = init_curl_client
        logger.debug body.to_json
        curl.http_post(body.to_json)

        logger.debug curl.body_str

        soapbody = JSON.parse(curl.body_str, symbolize_names: true)

        if curl.status.to_i >= 400
          close_curl(curl)
          raise(error_handler, soapbody)
        end

        close_curl(curl)

        soapbody
      end

      def close_curl(curl)
        curl.close
        # force process to kill socket
        GC.start
      end

      def hash_header(token, target_server = nil)
        context = { authToken: token, userAgent: { name: :zmsoap }, targetServer: target_server }.delete_if do |_, v|
          v.nil?
        end
        { Header: { context: context, _jsns: BASESPACE } }
      end
    end
  end
end
