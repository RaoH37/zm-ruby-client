# frozen_string_literal: true

module Zm
  module Client
    class Message
      # collection attachments
      class AttachmentsCollection
        include MissingMethodStaticCollection

        attr_reader :all

        def initialize
          @all = []
        end

        def add(attachment)
          return unless attachment.is_a?(Attachment)

          @all.push(attachment)
        end
      end

      # class attachment for email
      class Attachment
        attr_accessor :aid, :part, :mid, :ct, :s, :filename, :ci, :cd

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def download(dest_file_path)
          h = {
            id: @parent.id,
            part: part,
            auth: 'qp',
            zauthtoken: account.token,
            disp: 'a'
          }

          url = account.home_url

          url << '?' << Utils.format_url_params(h)

          uploader = @parent.build_uploader
          uploader.download_file_with_url(url, dest_file_path)
        end

        def account
          @parent.parent
        end
      end
    end
  end
end
