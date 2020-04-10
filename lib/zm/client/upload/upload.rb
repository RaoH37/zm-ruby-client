# frozen_string_literal: true

module Zm
  module Client
    # class for upload account file
    class Upload
      FMT_TYPES_H = {
          'ics' => ['appointment'],
          'vcard' => ['contact']
      }

      def initialize(parent, rac = nil)
        @parent = parent
        @rac = rac || @parent.rac
      end

      def download_file_with_url(url, dest_file_path)
        url = File.join(@parent.home_url, url) unless url.start_with?('http')

        @rac.download(url, dest_file_path)
      end

      def download_file(folder_path, fmt, types, ids, dest_file_path)
        @rac.download(download_file_url(folder_path, fmt, types, ids), dest_file_path)
      end

      def download_file_url(folder_path, fmt, types, ids = [])
        url_folder_path = File.join(@parent.home_url, folder_path.to_s)

        h = {
          fmt: fmt,
          types: query_value_types(types, fmt),
          emptyname: 'Vide',
          charset: 'UTF-8',
          auth: 'qp',
          zauthtoken: @parent.token,
          disp: 'a'
        }

        h.merge!(query_ids(ids))

        h.reject! { |_, v| is_blank?(v) }

        uri = Addressable::URI.new
        uri.query_values = h
        url_folder_path << '?' << uri.query

        # puts url_folder_path

        url_folder_path
      end

      def send_file(folder_path, fmt, types, resolve, src_file_path)
        @rac.upload(send_file_url(folder_path, fmt, types, resolve), src_file_path)
      end

      def send_file_url(folder_path, fmt, types, resolve)
        # resolve=[modfy|replace|reset|skip]
        url_folder_path = File.join(@parent.home_url, folder_path.to_s)

        h = {
          fmt: fmt,
          types: query_value_types(types, fmt),
          resolve: resolve,
          auth: 'qp',
          zauthtoken: @parent.token
        }

        h.reject! { |_, v| is_blank?(v) }

        uri = Addressable::URI.new
        uri.query_values = h

        url_folder_path << '?' << uri.query
        url_folder_path
      end

      def send_attachment(src_file_path)
        str = upload_attachment(src_file_path)
        AttachmentResponse.new(str)
      end

      def upload_attachment(src_file_path)
        @rac.upload(upload_attachment_url, src_file_path)
      end

      def upload_attachment_url
        @rac.cookie("ZM_AUTH_TOKEN=#{@parent.token}")
        uri = Addressable::URI.new
        uri.query_values = {
          fmt: 'extended,raw'
        }
        File.join(@parent.public_url, 'service/upload') << '?' << uri.query
      end

      def query_ids(ids)
        return {} if ids.nil?
        return { id: ids } unless ids.is_a?(Array)
        return { id: ids.first } if ids.length == 1
        return { list: ids.join(',') }
      end

      def query_value_types(types, fmt)
        types = FMT_TYPES_H[fmt] if types.nil?

        types = [types] unless types.is_a?(Array)
        types.join(',')
      end

      def is_blank?(v)
        return false if v.is_a?(Numeric)

        v.nil? || v.empty?
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
