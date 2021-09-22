# frozen_string_literal: true

module Zm
  module Client

    # Collection recipients
    class Recipients
      def initialize
        @recipients = []
      end

      def map(&block)
        @recipients.map(&block)
      end

      def add(recipient)
        return unless recipient.is_a?(Recipient)

        @recipients.push(recipient)
      end

      def del(recipient)
        if recipient.is_a?(Recipient)
          @recipients.delete(recipient)
        elsif recipient.is_a?(String)
          @recipients.delete_if { |r| r.email == recipient }
        end
      end

      def clear
        @recipients.clear
      end

      def to
        @recipients.select { |r| r.field == Recipient::TO }
      end

      def cc
        @recipients.select { |r| r.field == Recipient::CC }
      end

      def bcc
        @recipients.select { |r| r.field == Recipient::BCC }
      end

      def from
        @recipients.select { |r| r.field == Recipient::FROM }
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
    end
  end
end
