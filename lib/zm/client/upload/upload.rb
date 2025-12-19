# frozen_string_literal: true

module Zm
  module Client
    # class for upload mailbox file
    class Upload
      FMT_TYPES_H = {
        'ics' => FolderView::APPOINTMENT,
        'vcard' => FolderView::CONTACT,
        'eml' => FolderView::MESSAGE,
        'vcf' => FolderView::CONTACT
      }.freeze

      AUTHORIZED_FOLDER_FMT = %w[zip tgz ics csv tar xml json rss atom html ifb].freeze

      AUTHORIZED_PARAMS = %i[charset auth fmt id list types emptyname disp resolve query meta csvfmt].freeze

      AUTHORIZED_RESOLVE = %w[replace modify reset skip].freeze

      attr_reader :rest_connector
      attr_accessor :charset, :auth, :emptyname, :disp

      def initialize(base_url, token, is_token_admin: false, **rest_options)
        raise ZmError, 'base_url must to be present' if base_url.nil?

        @charset = 'UTF-8'
        @auth = 'co'
        @emptyname = 'Empty'
        @disp = 'a'

        yield(self) if block_given?

        @base_url = base_url

        @rest_connector = RestConnector.new(**rest_options) do |conn|
          conn.cookies = if is_token_admin
                           "ZM_ADMIN_AUTH_TOKEN=#{token}"
                         else
                           "ZM_AUTH_TOKEN=#{token}"
                         end
        end
      end

      def download_file(dest_file_path, file_id, type, fmt: nil)
        fmt ||= File.extname(dest_file_path)[1..]
        type ||= FMT_TYPES_H[fmt]

        raise RestError, 'Invalid fmt type' if type.nil? && fmt.nil?

        remote_url = download_file_url(fmt, type, file_id)
        @rest_connector.download(remote_url, dest_file_path)
      end

      def download_files(dest_file_path, file_ids, type, fmt: nil)
        fmt ||= File.extname(dest_file_path)[1..]
        type ||= FMT_TYPES_H[fmt]

        raise RestError, 'Invalid fmt type' if type.nil? && fmt.nil?

        remote_url = download_files_url(fmt, type, file_ids)
        @rest_connector.download(remote_url, dest_file_path)
      end

      def download_folder(dest_file_path, folder_id, fmt: nil)
        fmt ||= File.extname(dest_file_path)[1..]

        raise RestError, 'Unauthorized fmt parameter' unless AUTHORIZED_FOLDER_FMT.include?(fmt)

        remote_url = download_folder_url(folder_id, fmt)
        @rest_connector.download(remote_url, dest_file_path)
      end

      def send_file(src_file_path, folder_id, fmt: nil, type: nil, resolve: nil)
        fmt ||= File.extname(src_file_path)[1..]
        type ||= FMT_TYPES_H[fmt]
        resolve ||= AUTHORIZED_RESOLVE.first

        raise RestError, 'Unauthorized resolve parameter' unless AUTHORIZED_RESOLVE.include?(resolve)

        raise RestError, 'Invalid fmt type' if type.nil? && fmt.nil?

        remote_url = send_file_url(folder_id, fmt:, type:, resolve:)
        @rest_connector.upload(remote_url, src_file_path)
      end

      def upload_attachment(src_file_path)
        @rest_connector.upload(upload_attachment_url, src_file_path)
      end

      def build_params(**params)
        params.select! { |k, _| AUTHORIZED_PARAMS.include?(k) }

        params[:charset] ||= @charset
        params[:auth] ||= @auth
        params[:emptyname] ||= @emptyname
        params[:disp] ||= @disp

        params.compact!

        params
      end

      def format_url_params(params)
        params.map { |k, v| "#{k}=#{v}" }.join('&')
      end

      def format_url(url, str_params)
        return url if str_params.nil? || str_params.empty?

        "#{url}?#{str_params}"
      end

      def download_file_with_url(url, dest_file_path)
        url = File.join(@base_url, url) unless url.start_with?('http')
        @rest_connector.download(url, dest_file_path)
      end

      def download_folder_url(folder_id, fmt)
        h = build_params(fmt:, id: folder_id)

        format_url(@base_url, format_url_params(h))
      end

      def download_file_url(fmt, type, id)
        h = build_params(fmt:, types: type, id:)

        format_url(@base_url, format_url_params(h))
      end

      def download_files_url(fmt, type, ids)
        h = build_params(fmt:, types: type, list: ids.join(','))

        format_url(@base_url, format_url_params(h))
      end

      def send_file_url(folder_id, fmt:, type:, resolve:)
        h = build_params(fmt:, types: type, resolve:, id: folder_id)

        format_url(@base_url, format_url_params(h))
      end

      def upload_attachment_url
        h = {
          fmt: 'extended,raw'
        }

        File.join(@base_url, 'service/upload') << '?' << format_url_params(h)
      end
    end
  end
end
