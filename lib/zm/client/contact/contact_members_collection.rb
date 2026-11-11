# frozen_string_literal: true

module Zm
  module Client
    class ContactMembersCollection
      include Zm::Utils::MissingMethodStaticCollection

      attr_writer :all

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def internals
        @all.select(&:internal?)
      end

      def shared
        @all.select(&:shared?)
      end

      def frees
        @all.select(&:free?)
      end

      def ldaps
        @all.select(&:ldap?)
      end

      def add(new_member)
        return false unless new_member.is_a?(Zm::Client::ContactMember)

        current_member = @all.find { |m| m.type == new_member.type && m.value == new_member.value }

        if current_member.nil?
          new_member.add!
          @all << new_member
          return true
        end

        if current_member.op == Zm::Client::ContactMember::DEL
          current_member.add!
          return true
        end

        false
      end

      def remove(new_member)
        return false unless new_member.is_a?(Zm::Client::ContactMember)

        current_member = @all.find { |m| m.type == new_member.type && m.value == new_member.value }
        return false if current_member.nil?

        current_member.remove!

        true
      end
    end
  end
end
