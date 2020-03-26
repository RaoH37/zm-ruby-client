# frozen_string_literal: true

require 'openssl'
require 'curb'

module Zm
  module Client
    class RestAccountConnector
      attr_reader :verbose, :follow_location

      def initialize
        @verbose = false
        @follow_location = true
        @curl = easy_curl
      end

      def verbose!
        @verbose = true
        @curl.verbose = @verbose
      end

      def cookie(cookie)
        @curl.headers['Cookie'] = cookie
      end

      def download(url, dest_file_path)
        @curl.url = URI.escape(url)
        File.open(dest_file_path, 'wb') do |f|
          @curl.on_body do |data|
            f << data
            data.size
          end
          @curl.perform
        end
      end

      def upload(url, src_file_path)
        @curl.url = URI.escape(url)
        @curl.http_post(Curl::PostField.file('file', src_file_path))

        if @curl.status.to_i >= 400
          messages = [
            "Upload failure ! #{src_file_path}",
            extract_title(@curl.body_str)
          ].compact
          raise RestError, messages.join("\n")
        end

        @curl.body_str
      end

      private

      def easy_curl
        Curl::Easy.new do |curl|
          curl.timeout = 7200
          curl.enable_cookies = false
          curl.encoding = ''
          curl.ssl_verify_peer = false
          curl.multipart_form_post = true
          curl.verbose = verbose
          curl.follow_location = follow_location
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
