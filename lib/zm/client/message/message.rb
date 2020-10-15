# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[id date l su fr]
      attr_accessor *INSTANCE_VARIABLE_KEYS

      attr_accessor :subject
      attr_reader :recipients, :attachments, :body

      def initialize(parent, json = nil)
        @parent = parent
        @recipients = Recipients.new
        @subject = ''
        @body = Body.new
        @attachments = Attachments.new

        init_from_json(json) if json.is_a?(Hash)

        yield(self) if block_given?
      end

      def to_jsns
        {
          attach: @attachments.to_jsns,
          e: @recipients.to_jsns,
          su: { _content: @subject },
          mp: @body.to_jsns
        }
      end

      def send!
        @parent.sacc.send_msg(@parent.token, to_jsns)
      end

      def init_from_json(json)
        @id   = json[:id]
        @date = Time.at(json[:d]/1000)
        @l    = json[:l]
        @su   = json[:su]
        @fr   = json[:fr]

        json[:e].each do |e|
          recipient = Recipient.new(e[:t], e[:a], e[:p])
          @recipients.add(recipient)
        end
      end

      # content fo an email
      class Body
        attr_accessor :text, :html

        def text_jsns
          { ct: 'text/plain', content: { _content: @text } }
        end

        def html_jsns
          { ct: 'text/html', content: { _content: @html } }
        end

        def to_jsns
          [
            {
              ct: 'multipart/alternative',
              mp: [text_jsns, html_jsns]
            }
          ]
        end
      end

      # collection attachments
      class Attachments
        def initialize
          @attachments = []
        end

        def add(attachment)
          return unless attachment.is_a?(Attachment)

          @attachments.push(attachment)
        end

        def to_jsns
          @attachments.map(&:to_jsns)
        end
      end

      # class attachment for email
      class Attachment
        attr_accessor :aid, :part, :mid

        def initialize
          yield(self) if block_given?
        end

        def to_jsns
          {
            part: @part,
            mid: @mid,
            aid: @aid
          }.reject { |_, v| v.nil? }
        end
      end

      # Collection recipients
      class Recipients
        def initialize
          @recipients = []
        end

        def to_jsns
          @recipients.map(&:to_jsns)
        end

        def add(recipient)
          return unless recipient.is_a?(Recipient)

          @recipients.push(recipient)
        end

        def to
          @recipients.select { |r| r.field == :t }
        end

        def cc
          @recipients.select { |r| r.field == :c }
        end

        def bcc
          @recipients.select { |r| r.field == :b }
        end

        def from
          @recipients.select { |r| r.field == :f }
        end
      end

      # Class one recipient for email
      class Recipient
        FROM = :f
        TO = :t
        CC = :c
        BCC = :b

        attr_accessor :field, :email, :display_name

        def initialize(field, email, display_name = nil)
          @email = email
          @field = field.to_sym
          @display_name = display_name
        end

        def to_jsns
          {
            t: @field,
            a: @email,
            p: @display_name
          }.reject { |_, v| v.nil? }
        end
      end
    end
  end
end
