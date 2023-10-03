# frozen_string_literal: true

module Zm
  module Client
    class Message
      # Collection recipients
      class Recipients
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

      # Class one recipient for email
      class Recipient
        FROM = :f
        TO = :t
        CC = :c
        BCC = :b

        attr_accessor :field, :email
        attr_writer :display_name

        def initialize(field, email, display_name = nil)
          @email = email
          @field = field.to_sym
          @display_name = display_name
        end

        def display_name
          @display_name || "#{@email} (#{@display_name})"
        end
      end
    end
  end
end
