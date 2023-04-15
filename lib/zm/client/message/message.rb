# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::Object
      include BelongsToFolder
      include BelongsToTag

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

      def flags
        @flags ||= FlagsCollection.new(self)
      end

      def create!(*args)
        raise NotImplementedError
      end

      def modify!(*args)
        raise NotImplementedError
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def delete!
        jsns = { action: { op: :delete, id: @id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def unspam!
        jsns = { action: { op: '!spam', id: @parent.id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def spam!
        jsns = { action: { op: :spam, id: @parent.id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end

      def send!
        @parent.sacc.jsns_request(:SendMsgRequest, @parent.token, jsns_builder.to_jsns)
      end

      # content fo an email
      class Body
        attr_accessor :text, :html
      end

      def jsns_builder
        @jsns_builder ||= MessageJsnsBuilder.new(self)
      end
    end
  end
end
