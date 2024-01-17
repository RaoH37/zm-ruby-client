# frozen_string_literal: true

module Zm
  module Client
    class RestAccountConnector
      attr_reader :verbose, :follow_location

      def initialize
        @verbose = false
        @cookies = nil
        @follow_location = true
      end

      def verbose!
        @verbose = true
      end

      def cookies(cookies)
        @cookies = cookies
      end

      def download(url, dest_file_path)
        curl = init_curl_client(url)

        File.open(dest_file_path, 'wb') do |f|
          curl.on_body do |data|
            f << data
            data.size
          end

          curl.perform
        end

        if curl.status.to_i >= 400
          File.unlink(dest_file_path) if File.exist?(dest_file_path)

          message = "Download failure: #{curl.body_str} (status=#{curl.status})"
          close_curl(curl)
          raise RestError, message
        end

        dest_file_path
      end

      def upload(url, src_file_path)
        curl = init_curl_client(url)

        curl.http_post(Curl::PostField.file('file', src_file_path))

        if curl.status.to_i >= 400
          messages = [
            "Upload failure ! #{src_file_path}",
            extract_title(curl.body_str)
          ].compact
          close_curl(curl)
          raise RestError, messages.join("\n")
        end

        str = curl.body_str
        close_curl(curl)
        str
      end

      private

      def close_curl(curl)
        curl.close
        # force process to kill socket
        GC.start
      end

      def init_curl_client(url)
        ::Curl::Easy.new(url) do |curl|
          curl.timeout = 300
          curl.enable_cookies = false
          curl.encoding = ''
          curl.ssl_verify_peer = false
          curl.ssl_verify_host = 0
          curl.multipart_form_post = true
          curl.verbose = verbose
          curl.follow_location = follow_location
          curl.verbose = @verbose
          curl.cookies = @cookies
        end
      end

      def extract_title(str)
        str.scan(%r{<title>(.*)</title>}).first.first
      rescue StandardError
        nil
      end
    end
  end
end
