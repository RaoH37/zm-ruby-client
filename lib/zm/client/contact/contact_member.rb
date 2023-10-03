# frozen_string_literal: true

module Zm
  module Client
    class ConcatMember
      INTERNAL = 'C'
      FREE     = 'I'
      LDAP     = 'G'
      ADD      = '+'
      DEL      = '-'

      attr_reader :type, :value, :op

      def initialize(type, value, op = nil)
        @op = op
        @type = type
        @value = value
      end

      def internal?
        @type == INTERNAL && !Zm::Client::Regex::SHARED_CONTACT.match(value)
      end

      def shared?
        @type == INTERNAL && Zm::Client::Regex::SHARED_CONTACT.match(value)
      end

      def free?
        @type == FREE
      end

      def ldap?
        @type == LDAP
      end

      def current?
        @op.nil?
      end

      def add!
        @op = ADD
      end

      def remove!
        @op = DEL
      end
    end
  end
end
