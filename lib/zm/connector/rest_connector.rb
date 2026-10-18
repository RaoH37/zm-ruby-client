# frozen_string_literal: true

require 'faraday/multipart'
require 'uri'

module Zm
  module Connector
    class RestConnector
      include NetworkErrorHandler

      attr_reader :verbose, :timeout
      attr_writer :cookies

      def initialize(verbose: false, timeout: 300, ssl_options: SSL_VERIFY_NONE)
        @verbose = verbose
        @timeout = timeout
        @ssl_options = ssl_options

        @cookies = nil

        yield(self) if block_given?
      end

      def download(download_url, dest_file_path)
        url, path = split_url(download_url)

        response = File.open(dest_file_path, 'wb') do |f|
          stream_get(url, path) { |chunk| f.write(chunk) }
        end

        return if response.status < 400

        raise Zm::Error::RestError, "Download failure: #{response.body} (status=#{response.status})"
      rescue Zm::Error::ConnectionError, Zm::Error::RestError
        FileUtils.rm_f(dest_file_path)
        raise
      end

      def read(download_url)
        url, path = split_url(download_url)

        data = +''
        response = stream_get(url, path) { |chunk| data.concat(chunk) }

        if response.status >= 400
          raise Zm::Error::RestError, "Download failure: #{response.body} (status=#{response.status})"
        end

        data
      end

      def upload(upload_url, src_file_path)
        url, path = split_url(upload_url)

        conn = Faraday.new(**http_options(url)) do |faraday|
          faraday.request :multipart
          add_logger(faraday)
        end

        payload = { file: Faraday::Multipart::FilePart.new(src_file_path, nil) }
        response = handle_network_errors { conn.post(path, payload) }

        upload_return(response, failure_message: "Upload failure ! #{src_file_path}")
      end

      private

      def stream_get(url, path, &on_chunk)
        conn = conn_get(url)

        handle_network_errors do
          conn.get(path) do |request|
            request.options.on_data = proc { |chunk, _, _| on_chunk.call(chunk) }
          end
        end
      end

      def conn_get(url)
        Faraday.new(**http_options(url)) do |faraday|
          add_logger(faraday)
        end
      end

      def add_logger(faraday)
        return unless @verbose

        faraday.response(:logger, nil, { headers: true, bodies: true, errors: true }) do |formatter|
          Zm::Utils::LogFilter.apply(formatter)
        end
      end

      def upload_return(response, failure_message: 'Upload failure')
        if response.status >= 400
          messages = [
            failure_message,
            extract_title(response.body)
          ].compact

          raise Zm::Error::RestError, messages.join("\n")
        end

        response.body
      end

      def split_url(url)
        uri = URI(url)
        url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        path = uri.query ? "#{uri.path}?#{uri.query}" : uri.path

        [url, path]
      end

      def headers
        { 'Cookie' => @cookies, 'User-Agent' => 'ZmRubyClient' }
      end

      def http_options(url)
        {
          url:,
          headers:,
          request: {
            timeout: @timeout
          },
          ssl: @ssl_options
        }
      end

      def extract_title(str)
        str.scan(%r{<title>(.*)</title>}).first.first
      rescue StandardError
        nil
      end
    end
  end
end
