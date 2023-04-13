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

        # def to_jsns
        #   @all.map(&:to_jsns)
        # end

        def add(recipient)
          return unless recipient.is_a?(Recipient)

          @all.push(recipient)
        end

        def to
          @all.select { |r| r.field == Recipient::TO }
        end

        def cc
          @all.select { |r| r.field == Recipient::CC }
        end

        def bcc
          @all.select { |r| r.field == Recipient::BCC }
        end

        def from
          @all.select { |r| r.field == Recipient::FROM }
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

        # def to_jsns
        #   {
        #    t: @field,
        #    a: @email,
        #    p: display_name
        #   }.reject { |_, v| v.nil? }
        # end
      end
    end
  end
end
