# frozen_string_literal: true

module Zm
  module Client
    class ConcatMember
      INTERNAL = 'C'.freeze
      FREE     = 'I'.freeze
      LDAP     = 'G'.freeze
      ADD      = '+'.freeze
      DEL      = '-'.freeze

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
        @type == INTERNAL
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
        node = {type: @type, value: @value}
        node[:op] = @op if !@op.nil?
        node
      end
    end
  end
end
