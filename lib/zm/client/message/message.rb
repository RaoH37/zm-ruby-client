# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::Object
      include BelongsToFolder
      include BelongsToTag

      attr_accessor :id, :d, :l, :f, :su, :fr, :autoSendTime, :mid, :idnt, :tn, :subject, :s

      alias size s

      def initialize(parent)
        @parent = parent
        @subject = ''

        yield(self) if block_given?
      end

      def recipients
        return @recipients if defined? @recipients

        @recipients = Recipients.new
      end

      def attachments
        return @attachments if defined? @attachments

        @attachments = AttachmentsCollection.new
      end

      def body
        return @body if defined? @body

        @body = Body.new
      end

      def download(dest_file_path, fmt = 'eml')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file( Zm::Client::FolderDefault::ROOT[:path], fmt, [Zm::Client::FolderView::MESSAGE], [@id], dest_file_path)
      end

      def read(fmt = 'eml')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.read_file( Zm::Client::FolderDefault::ROOT[:path], fmt, [Zm::Client::FolderView::MESSAGE], [@id])
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

      def modify!(*args)
        raise NotImplementedError
      end

      def update!(l: nil, rgb: nil, color: nil, f: nil, tn: nil)
        attrs = {
          op: :update,
          id: @id,
          l: l,
          rgb: rgb,
          color: color,
          f: f,
          tn: tn
        }

        attrs.delete_if { |_, v| v.nil? }

        soap_request = SoapElement.mail(SoapMailConstants::MSG_ACTION_REQUEST)
        node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
        soap_request.add_node(node_action)
        @parent.sacc.invoke(soap_request)
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
      end

      def unspam!
        @parent.sacc.invoke(jsns_builder.to_unspam)
      end

      def spam!
        @parent.sacc.invoke(jsns_builder.to_spam)
      end

      def send!
        soap_request = SoapElement.mail(SoapMailConstants::SEND_MSG_REQUEST).add_attributes(jsns_builder.to_jsns)
        @parent.sacc.invoke(soap_request)
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
