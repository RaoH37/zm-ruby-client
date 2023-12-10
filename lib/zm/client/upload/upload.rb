# frozen_string_literal: true

module Zm
  module Client
    # class for upload account file
    class Upload
      FMT_TYPES_H = {
        'ics' => ['appointment'],
        'vcard' => ['contact']
      }.freeze

      def initialize(parent, rac = nil)
        @parent = parent
        @rac = rac || @parent.rac
        @rac.cookies("ZM_AUTH_TOKEN=#{@parent.token}")
      end

      def download_file_with_url(url, dest_file_path)
        raise ZmError, 'home_url is not defined' if @parent.home_url.nil?

        url = File.join(@parent.home_url, url) unless url.start_with?('http')
        @rac.download(url, dest_file_path)
      end

      def download_file(folder_path, fmt, types, ids, dest_file_path)
        @rac.download(download_file_url(folder_path, fmt, types, ids), dest_file_path)
      end

      def download_folder(id, fmt, dest_file_path)
        @rac.download(download_folder_url(id, fmt), dest_file_path)
      end

      def download_folder_url(id, fmt)
        raise ZmError, 'home_url is not defined' if @parent.home_url.nil?

        url_folder_path = @parent.home_url.dup

        h = {
          fmt: fmt,
          id: id,
          emptyname: 'Empty',
          charset: 'UTF-8',
          auth: 'co',
          disp: 'a'
        }

        url_folder_path << '?' << Utils.format_url_params(h)

        url_folder_path
      end

      def download_file_url(folder_path, fmt, types, ids = [])
        raise ZmError, 'home_url is not defined' if @parent.home_url.nil?

        url_folder_path = File.join(@parent.home_url, folder_path.to_s)

        h = {
          fmt: fmt,
          types: query_value_types(types, fmt),
          emptyname: 'Empty',
          charset: 'UTF-8',
          auth: 'co',
          disp: 'a'
        }

        h.merge!(query_ids(ids))

        h.reject! { |_, v| is_blank?(v) }

        url_folder_path << '?' << Utils.format_url_params(h)

        url_folder_path
      end

      def send_file(folder_path, fmt, types, resolve, src_file_path)
        @rac.upload(send_file_url(folder_path, fmt, types, resolve), src_file_path)
      end

      def send_file_url(folder_path, fmt, types, resolve)
        raise ZmError, 'home_url is not defined' if @parent.home_url.nil?

        # resolve=[modfy|replace|reset|skip]
        url_folder_path = File.join(@parent.home_url, folder_path.to_s)

        h = {
          fmt: fmt,
          types: query_value_types(types, fmt),
          resolve: resolve,
          auth: 'co'
        }

        h.reject! { |_, v| is_blank?(v) }

        url_folder_path << '?' << Utils.format_url_params(h)

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
        h = {
          fmt: 'extended,raw'
        }

        File.join(@parent.public_url, 'service/upload') << '?' << Utils.format_url_params(h)
      end

      def query_ids(ids)
        return {} if ids.nil?
        return { id: ids } unless ids.is_a?(Array)
        return { id: ids.first } if ids.length == 1

        { list: ids.join(',') }
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
