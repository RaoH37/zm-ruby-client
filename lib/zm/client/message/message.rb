# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::AccountObject
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

      def date
        @date ||= Time.at(d.to_i / 1000)
      end

      def tags
        @tags ||= AccountObject::TagsCollection.new(self)
      end

      def flags
        @flags ||= FlagsCollection.new(self)
      end

      def folder=(folder)
        @folder = folder
        @l = folder.id
      end

      def delete!
        jsns = { action: { op: :delete, id: @parent.id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def move!(new_folder_id)
        new_folder_id = new_folder_id.id if new_folder_id.is_a?(Zm::Client::Folder)
        jsns = { action: { op: :move, id: @item.id, l: new_folder_id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
        @l = new_folder_id
        folder!
      end

      def folder
        @folder || folder!
      end

      def folder!
        @folder = @parent.folders.all.find { |folder| folder.id == @l }
      end

      def unspam!
        jsns = { action: { op: '!spam', id: @parent.id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def spam!
        jsns = { action: { op: :spam, id: @parent.id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def trash!
        jsns = { action: { op: :trash, id: @parent.id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def send!
        # @parent.sacc.send_msg(@parent.token, jsns_builder.to_jsns)
        @parent.sacc.jsns_request(:SendMsgRequest, @parent.token, jsns_builder.to_jsns)
      end

      # content fo an email
      class Body
        attr_accessor :text, :html

        # def text_jsns
        #   @text.nil? ? nil : { ct: ContentType::TEXT, content: { _content: @text } }
        # end
        #
        # def html_jsns
        #   @html.nil? ? nil : { ct: ContentType::HTML, content: { _content: @html } }
        # end
        #
        # def to_jsns
        #   [
        #     {
        #       ct: 'multipart/alternative',
        #       mp: [text_jsns, html_jsns].compact
        #     }
        #   ]
        # end
      end

      def jsns_builder
        @jsns_builder ||= MessageJsnsBuilder.new(self)
      end
    end
  end
end
