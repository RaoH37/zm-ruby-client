# frozen_string_literal: true

module Zm
  module Connector
    class SoapBaseConnector
      include NetworkErrorHandler

      BASESPACE = 'urn:zimbra'
      HTTP_HEADERS = {
        'Content-Type' => 'application/json; charset=utf-8',
        'User-Agent' => 'ZmRubyClient'
      }.freeze
      CACHEABLE_REQUEST_REGEX = /\A(?:Get|Search|Count)\w*Request\z/

      attr_reader :context
      attr_writer :logger, :cache, :timeout, :ssl_options

      def initialize(url, soap_path)
        @verbose = false
        @timeout = 300

        @ssl_options = SSL_VERIFY_NONE

        @url = url
        @soap_path = soap_path

        @context = Zm::SoapRequest::SoapContext.new
      end

      def verbose!
        @verbose = true
      end

      def invoke(soap_element, error_handler = Zm::Error::SoapError)
        do_request(envelope(soap_element), error_handler, cacheable: cacheable?(soap_element))[:Body]
      end

      def target_invoke(soap_element, target_id, error_handler = Zm::Error::SoapError)
        @context.target_server(target_id)
        invoke(soap_element, error_handler)
      ensure
        @context.target_server(nil)
      end

      def http_client!
        @http_client = Faraday.new(
          url: @url,
          headers: HTTP_HEADERS,
          request: {
            timeout: @timeout
          },
          ssl: @ssl_options
        ) do |faraday|
          faraday.request :json
          if @verbose
            faraday.response(:logger, nil, { headers: true, bodies: true, errors: true }) do |formatter|
              Zm::Utils::LogFilter.apply(formatter)
            end
          end
        end
      end

      private

      def cacheable?(soap_element)
        CACHEABLE_REQUEST_REGEX.match?(soap_element.name)
      end

      def http_client
        @http_client || http_client!
      end

      def do_request(body, error_handler = Zm::Error::SoapError, cacheable: false)
        json_body = body.to_json
        @logger.debug { Zm::Utils::LogFilter.filter(json_body) }

        json_response = if cacheable
                          @cache.fetch(json_body) { post(json_body, error_handler) }
                        else
                          post(json_body, error_handler)
                        end

        JSON.parse(json_response, symbolize_names: true)
      end

      def post(json_body, error_handler)
        @logger.debug 'Load from remote'
        response = handle_network_errors { http_client.post(@soap_path, json_body) }
        @logger.debug { Zm::Utils::LogFilter.filter(response.body) }

        raise(error_handler, error_body(response)) if response.status >= 400

        response.body
      end

      def error_body(response)
        JSON.parse(response.body, symbolize_names: true)
      rescue JSON::ParserError, TypeError
        { Body: { Fault: { Reason: { Text: "HTTP #{response.status}" }, Detail: { Error: { Code: 'HTTP_ERROR' } } } } }
      end

      def envelope(soap_element)
        {
          Body: soap_element.to_hash,
          Header: { context: context.to_hash, _jsns: BASESPACE }
        }
      end
    end
  end
end
