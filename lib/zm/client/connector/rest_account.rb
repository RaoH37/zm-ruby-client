# frozen_string_literal: true

require 'openssl'
require 'curb'

module Zm
  module Client
    class RestAccountConnector
      attr_accessor :verbose

      def initialize
        @curl = easy_curl
        @verbose = false
      end

      def cookie(cookie)
        @curl.headers['Cookie'] = cookie
      end

      def download(url, dest_file_path)
        Curl::Easy.download(url, dest_file_path)
      end

      def upload(url, src_file_path)
        @curl.url = url
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

      def multi_upload(url_fields)
        easy_options = {
          follow_location: false,
          enable_cookies: false,
          ssl_verify_peer: false,
          verbose: verbose,
          multipart_form_post: true
        }
        multi_options = { pipeline: Curl::CURLPIPE_HTTP1 }

        curl_fields = url_fields.map { |path, url| { url: url, post_fields: { file: path } } }
        puts curl_fields

        Curl::Multi.post(curl_fields, easy_options, multi_options) do |easy|
          # do something interesting with the easy response
          puts easy.body_str
        end

        # responses = {}
        # m = Curl::Multi.new
        # url_fields.each do |url, src_file_path|
        #   responses[url] = ''
        #   m.add(easy_curl)
        # end
        #
        # m.perform do
        #   puts "idling... can do some work here"
        # end
        #
        # requests.each do|url|
        #   puts responses[url]
        # end
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
        end
      end

      def extract_title(str)
        str.scan(/<title>(.*)<\/title>/).first.first
      rescue
        nil
      end
    end
  end
end
