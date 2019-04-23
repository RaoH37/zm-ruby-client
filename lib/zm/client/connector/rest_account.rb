require 'openssl'
require 'curb'

module Zm
  module Client
    class RestAccountConnector
      def download(url, dest_file_path)
        Curl::Easy.download(url, dest_file_path)
      end

      def upload(url, src_file_path)
        curb = Curl::Easy.new(url) do |curl|
          curl.timeout = 72000
          curl.enable_cookies = false
          curl.encoding = ''
          curl.ssl_verify_peer = false
          curl.multipart_form_post = true
        end

        curb.http_post(Curl::PostField.file('file', src_file_path))
      end
    end
  end
end
