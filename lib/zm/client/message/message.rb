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

      def jsns_builder
        @jsns_builder ||= MessageJsnsBuilder.new(self)
      end
    end
  end
end
