# frozen_string_literal: true

require 'faraday/multipart'

module Zm
  module Client
    class RestAccountConnector
      attr_reader :verbose, :follow_location

      def initialize
        @verbose = false
        @timeout = 300

        @ssl_options = {
          verify: false,
          verify_hostname: false,
          verify_mode: OpenSSL::SSL::VERIFY_NONE
        }

        @cookies = nil
      end

      def verbose!
        @verbose = true
      end

      def cookies(cookies)
        @cookies = cookies
      end

      def download(download_url, dest_file_path)
        url, path = split_url(download_url)

        conn = Faraday.new(**http_options(url)) do |faraday|
          faraday.response :logger, nil, { headers: true, bodies: true, errors: true } if @verbose
        end

        response = nil

        File.open(dest_file_path, 'wb') do |f|
          response = conn.get(path) do |request|
            request.options.on_data = Proc.new do |chunk, _, _|
              f.write chunk
            end
          end
        end

        if response.status >= 400
          File.unlink(dest_file_path) if File.exist?(dest_file_path)
          raise RestError, "Download failure: #{response.body} (status=#{response.status})"
        end
      end

      def upload(upload_url, src_file_path)
        url, path = split_url(upload_url)

        conn = Faraday.new(**http_options(url)) do |faraday|
          faraday.request :multipart
          faraday.response :logger, nil, { headers: true, bodies: true, errors: true } if @verbose
        end

        payload = { file: Faraday::Multipart::FilePart.new(src_file_path, nil) }
        response = conn.post(path, payload)

        if response.status >= 400
          messages = [
            "Upload failure ! #{src_file_path}",
            extract_title(response.body)
          ].compact

          raise RestError, messages.join("\n")
        end

        response.body
      end

      private

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
