# frozen_string_literal: true

module Zm
  module Client
    class MessageRecipients
      attr_reader :all

      def initialize
        @all = []
      end

      def add(recipient)
        return unless recipient.is_a?(Zm::Client::Recipient)

        @all.push(recipient)
      end

      def to
        @all.select { |r| r.field == Zm::Client::Recipient::TO }
      end

      def cc
        @all.select { |r| r.field == Zm::Client::Recipient::CC }
      end

      def bcc
        @all.select { |r| r.field == Zm::Client::Recipient::BCC }
      end

      def from
        @all.select { |r| r.field == Zm::Client::Recipient::FROM }
      end
    end
  end
end
