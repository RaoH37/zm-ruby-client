# frozen_string_literal: true

module Zm
  module Client
    # class for account message jsns builder
    class MessageJsnsBuilder
      def initialize(item)
        @item = item
      end

      def to_jsns
        jsns = {
          id: @item.id,
          attach: attachments_jsns,
          e: recipients_jsns,
          su: { _content: @item.su },
          mp: body_jsns
        }.delete_if { |_, v| v.nil? }

        jsns[:did] = @item.id if @item.l.to_i == FolderDefault::DRAFTS[:id]

        jsns
      end

      def attachments_jsns
        @item.attachments.all.map do |attachment|
          {
            part: attachment.part,
            mid: attachment.mid,
            aid: attachment.aid,
            ct: attachment.ct,
            s: attachment.s,
            filename: attachment.filename,
            ci: attachment.ci,
            cd: attachment.cd
          }.reject { |_, v| v.nil? }
        end
      end

      def recipients_jsns
        return nil if @item.recipients.all.empty?

        @item.recipients.all.map do |recipient|
          {
            t: recipient.field,
            a: recipient.email,
            p: recipient.display_name
          }.reject { |_, v| v.nil? }
        end
      end

      def body_jsns
        return nil if @item.body.text.nil? && @item.body.html.nil?

        text_jsns = @item.body.text.nil? ? nil : { ct: ContentType::TEXT, content: { _content: @item.body.text } }
        html_jsns = @item.body.html.nil? ? nil : { ct: ContentType::HTML, content: { _content: @item.body.html } }

        [
          {
            ct: 'multipart/alternative',
            mp: [text_jsns, html_jsns].compact
          }
        ]
      end
    end
  end
end
