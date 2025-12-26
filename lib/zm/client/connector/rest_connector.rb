# frozen_string_literal: true

require 'faraday/multipart'
require 'uri'

module Zm
  module Client
    class RestConnector
      attr_reader :verbose, :timeout
      attr_writer :cookies

      def initialize(verbose: false, timeout: 300)
        @verbose = verbose
        @timeout = timeout

        @ssl_options = {
          verify: false,
          verify_hostname: false,
          verify_mode: OpenSSL::SSL::VERIFY_NONE
        }

        @cookies = nil

        yield(self) if block_given?
      end

      def download(download_url, dest_file_path)
        url, path = split_url(download_url)

        conn = conn_get(url)

        response = nil

        File.open(dest_file_path, 'wb') do |f|
          response = conn.get(path) do |request|
            request.options.on_data = proc do |chunk, _, _|
              f.write chunk
            end
          end
        end

        return unless response.status >= 400

        FileUtils.rm_f(dest_file_path)
        raise RestError, "Download failure: #{response.body} (status=#{response.status})"
      end

      def read(download_url)
        url, path = split_url(download_url)

        conn = conn_get(url)

        data = +''

        response = conn.get(path) do |request|
          request.options.on_data = Proc.new do |chunk, _, _|
            data.concat(chunk)
          end
        end

        if response.status >= 400
          raise RestError, "Download failure: #{response.body} (status=#{response.status})"
        end

        data
      end

      def upload(upload_url, src_file_path)
        url, path = split_url(upload_url)

        conn = Faraday.new(**http_options(url)) do |faraday|
          faraday.request :multipart
          faraday.response :logger, nil, { headers: true, bodies: true, errors: true } if @verbose
        end

        payload = { file: Faraday::Multipart::FilePart.new(src_file_path, nil) }
        response = conn.post(path, payload)

        upload_return(response, failure_message: "Upload failure ! #{src_file_path}")
      end

      private

      def conn_get(url)
        Faraday.new(**http_options(url)) do |faraday|
          faraday.response :logger, nil, { headers: true, bodies: true, errors: true } if @verbose
        end
      end

      def upload_return(response, failure_message: 'Upload failure')
        if response.status >= 400
          messages = [
            failure_message,
            extract_title(response.body)
          ].compact

          raise RestError, messages.join("\n")
        end

        response.body
      end

      def split_url(url)
        uri = URI(url)
        url = "#{uri.scheme}://#{uri.host}:#{uri.port}"
        path = [uri.path, uri.query].join('?')

        [url, path]
      end

      def headers
        { 'Cookie' => @cookies, 'User-Agent' => 'ZmRubyClient' }
      end

      def http_options(url)
        {
          url: url,
          headers: headers,
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
