# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::Object
      include BelongsToFolder
      include BelongsToTag
      include RequestMethodsMailbox
      include MailboxItemConcern

      attr_accessor :d, :f, :su, :fr, :autoSendTime, :mid, :idnt, :tn, :subject, :s
      attr_reader :recipients, :attachments, :body

      alias size s

      def initialize(parent)
        @parent = parent
        @subject = ''

        @recipients = Recipients.new
        @body = Body.new
        @attachments = AttachmentsCollection.new

        yield(self) if block_given?
      end

      def download(dest_file_path, fmt: 'eml')
        uploader = @parent.build_uploader
        uploader.download_file(dest_file_path, id, FolderView::MESSAGE, fmt:)
      end

      def read
        uploader = @parent.build_uploader
        uploader.read_file(id, FolderView::MESSAGE, fmt: 'eml')
      end

      def date
        return @date if defined? @date

        @date = Time.at(d.to_i / 1000)
      end

      def flags
        return @flags if defined? @flags

        @flags = FlagsCollection.new(self)
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

      def update!(attrs)
        authorized_keys = %i[l rgb color f tn]

        attrs.reject! { |k| !authorized_keys.include?(k) }

        attrs.merge!({ op: :update, id: id })

        attrs.compact!

        soap_request = SoapElement.mail(SoapMailConstants::ITEM_ACTION_REQUEST)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
        soap_request.add_node(node_action)
        @parent.soap_connector.invoke(soap_request)
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
      end

      def unspam!
        @parent.soap_connector.invoke(build_unspam)
      end

      def build_unspam
        jsns_builder.to_unspam
      end

      def spam!
        @parent.soap_connector.invoke(build_spam)
      end

      def build_spam
        jsns_builder.to_spam
      end

      def send!
        @parent.soap_connector.invoke(build_send)
      end

      def build_send
        SoapElement.mail(SoapMailConstants::SEND_MSG_REQUEST)
                   .add_attributes(jsns_builder.to_jsns)
      end

      # content fo an email
      class Body
        attr_accessor :text, :html
      end

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = MessageJsnsBuilder.new(self)
      end
    end
  end
end
