# frozen_string_literal: true

module Zm
  module Client
    class ConcatMember
      INTERNAL = 'C'
      FREE     = 'I'
      LDAP     = 'G'
      ADD      = '+'
      DEL      = '-'

      class << self
        def find_type_by_value(value)
          return INTERNAL if !value.to_i.zero? || Zm::Client::Regex::SHARED_CONTACT.match(value)
          return LDAP if Zm::Client::Regex::BASEDN_REGEX.match(value)

          FREE
        end

        def init_by_value(value)
          type_v = find_type_by_value(value)
          new(type_v, value)
        end
      end

      attr_reader :type, :value, :op

      def initialize(type, value, op = nil)
        @op = op
        @type = type
        @value = value
      end

      def concat
        [@value, @type, @op]
      end

      def to_s
        concat.join(' :: ')
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

      def add!
        @op = ADD
      end

      def remove!
        @op = DEL
      end

      def construct_soap_node
        node = { type: @type, value: @value }
        node[:op] = @op unless @op.nil?
        node
      end
    end
  end
end
