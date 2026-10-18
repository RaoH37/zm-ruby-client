# frozen_string_literal: true

module Zm
  module Client
    class MessageAttachmentsCollection
      include Zm::Utils::MissingMethodStaticCollection

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
        account.build_uploader.download_attachment(dest_file_path, @parent.id, part)
      end

      def account
        @parent.parent
      end
    end
  end
end
