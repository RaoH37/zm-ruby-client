# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::Object
      include BelongsToFolder
      include BelongsToTag
      include RequestMethodsMailbox

      attr_accessor :id, :d, :l, :f, :su, :fr, :autoSendTime, :mid, :idnt, :tn, :subject
      attr_reader :recipients, :attachments, :body

      def initialize(parent)
        @parent = parent
        @subject = ''

        @recipients = Recipients.new
        @body = Body.new
        @attachments = AttachmentsCollection.new

        yield(self) if block_given?
      end

      def download(dest_file_path, fmt = 'eml')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(
          Zm::Client::FolderDefault::ROOT[:path],
          fmt,
          [Zm::Client::FolderView::MESSAGE],
          [@id],
          dest_file_path
        )
      end

      def date
        @date ||= Time.at(d.to_i / 1000)
      end

      def flags
        @flags ||= FlagsCollection.new(self)
      end

      def create!(*args)
        raise NotImplementedError
      end

      def build_create
        raise NotImplementedError
      end

      def modify!(*args)
        raise NotImplementedError
      end

      def build_modify
        raise NotImplementedError
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
      end

      def unspam!
        @parent.sacc.invoke(build_unspam)
      end

      def build_unspam
        jsns_builder.to_unspam
      end

      def spam!
        @parent.sacc.invoke(build_spam)
      end

      def build_spam
        jsns_builder.to_spam
      end

      def send!
        @parent.sacc.invoke(build_send)
      end

      def build_send
        SoapElement.mail(SoapMailConstants::SEND_MSG_REQUEST).add_attributes(jsns_builder.to_jsns)
      end

      # content fo an email
      class Body
        attr_accessor :text, :html
      end

      def sacc
        @parent.sacc
      end

      def jsns_builder
        @jsns_builder ||= MessageJsnsBuilder.new(self)
      end
    end
  end
end
