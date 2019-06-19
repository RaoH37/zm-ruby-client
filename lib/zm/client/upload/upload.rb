# frozen_string_literal: true

module Zm
  module Client
    # class for upload account file
    class Upload
      def initialize(parent)
        @parent = parent
      end

      def download_file(folder_path, fmt, types, dest_file_path)
        @parent.rac.download(download_file_url(folder_path, fmt, types), dest_file_path)
      end

      def download_file_url(folder_path, fmt, types)
        url_folder_path = File.join(@parent.home_url, folder_path.to_s)
        uri = Addressable::URI.new
        uri.query_values = {
          fmt: fmt,
          types: types.join(','),
          emptyname: 'Vide',
          charset: 'UTF-8',
          auth: 'qp',
          zauthtoken: @parent.token
        }
        url_folder_path << '?' << uri.query
        url_folder_path
      end

      def send_file(folder_path, fmt, types, resolve, src_file_path)
        @parent.rac.upload(send_file_url(folder_path, fmt, types, resolve), src_file_path)
      end

      def send_file_url(folder_path, fmt, types, resolve)
        url_folder_path = File.join(@parent.home_url, folder_path.to_s)
        uri = Addressable::URI.new
        uri.query_values = {
          fmt: fmt,
          types: types.join(','),
          resolve: resolve,
          auth: 'qp',
          zauthtoken: @parent.token
        }
        url_folder_path << '?' << uri.query
        url_folder_path
      end

      def send_attachment(src_file_path)
        str = @parent.rac.upload(upload_attachment_url, src_file_path)
        AttachmentResponse.new(str)
      end

      def upload_attachment_url
        @parent.rac.cookie("ZM_AUTH_TOKEN=#{@parent.token}")
        uri = Addressable::URI.new
        uri.query_values = {
          fmt: 'extended,raw'
        }
        File.join(@parent.public_url, 'service/upload') << '?' << uri.query
      end
    end

    # class to parse upload attachment response
    class AttachmentResponse
      def initialize(str)
        @str = str
        @str_h = JSON.parse(str[str.index('['), str.length], symbolize_names: true).first
      end

      def aid
        @str_h[:aid]
      end
    end
  end
end
