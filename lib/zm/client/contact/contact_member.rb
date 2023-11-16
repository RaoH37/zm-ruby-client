# frozen_string_literal: true

module Zm
  module Client
    class ConcatMember
      include Zm::Inspector

      INTERNAL = 'C'
      FREE     = 'I'
      LDAP     = 'G'
      ADD      = '+'
      DEL      = '-'

      attr_reader :type, :value, :op, :shared_account_id

      def initialize(type, value, op = nil)
        @shared_account_id = nil
        @op = op
        @type = type

        value_int = value.to_i

        if !value_int.zero?
          @value = value_int
        elsif Zm::Client::Regex::SHARED_CONTACT.match(value)
          part_value = value.split(':')
          @shared_account_id = part_value.first
          @value = part_value.last.to_i
        else
          @value = value
        end
      end

      def internal?
        @type == INTERNAL && @value.is_a?(Integer)
      end

      def shared?
        @type == INTERNAL && !@shared_account_id.nil?
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

      def email_address
        return unless ldap?

        @email_address ||= @value.sub('uid=', '').sub(',ou=people,dc=', '@').gsub(',dc=', '.')
      end

      def instance_variables_map
        email_address
        super
      end
    end
  end
end
