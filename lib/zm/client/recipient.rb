# frozen_string_literal: true

module Zm
  module Client
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
