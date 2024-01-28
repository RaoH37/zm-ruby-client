# frozen_string_literal: true

require 'json'
require 'openssl'
require 'uri'

require_relative 'soap_error'

module Zm
  module Client
    class SoapBaseConnector
      include ZmLogger

      BASESPACE = 'urn:zimbra'
      HTTP_HEADERS = {
        'Content-Type' => 'application/json; charset=utf-8',
        'User-Agent' => 'ZmRubyClient'
      }.freeze

      attr_reader :context

      def initialize(scheme, host, port, soap_path)
        @verbose = false
        @timeout = 300

        @ssl_options = {
          verify: false,
          verify_hostname: false,
          verify_mode: OpenSSL::SSL::VERIFY_NONE
        }

        @soap_path = soap_path
        @uri = URI::HTTP.new(scheme, nil, host, port, nil, nil, nil, nil, nil)
        @context = SoapContext.new
      end

      def verbose!
        @verbose = true
      end

      def invoke(soap_element, error_handler = SoapError)
        do_request(envelope(soap_element), error_handler)[:Body]
      end

      def target_invoke(soap_element, target_id, error_handler = SoapError)
        @context.target_server(target_id)
        resp = invoke(soap_element, error_handler)
        @context.target_server(nil)
        resp
      end

      def http_client!
        @http_client = Faraday.new(
          url: @uri.to_s,
          headers: HTTP_HEADERS,
          request: {
            timeout: @timeout
          },
          ssl: @ssl_options
        ) do |faraday|
          faraday.request :json
          faraday.response :logger, nil, { headers: true, bodies: true, errors: true } if @verbose
        end
      end

      private

      def http_client
        @http_client || http_client!
      end

      def do_request(body, error_handler = SoapError)
        response = http_client.post(@soap_path, body)

        soapbody = JSON.parse(response.body, symbolize_names: true)

        if response.status >= 400
          raise(error_handler, soapbody)
        end

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
