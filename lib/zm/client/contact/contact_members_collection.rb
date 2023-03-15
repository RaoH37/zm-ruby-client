# frozen_string_literal: true

module Zm
  module Client
    class ContactMembersCollection
      attr_accessor :all

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def add(new_member)
        return false unless new_member.is_a?(Zm::Client::ConcatMember)

        current_member = @all.find { |m| m.type == new_member.type && m.value == new_member.value }

        if current_member.nil?
          new_member.add!
          @all << new_member
          return true
        end

        if current_member.op == Zm::Client::ConcatMember::DEL
          current_member.add!
          return true
        end

        false
      end

      def remove(new_member)
        return false unless new_member.is_a?(Zm::Client::ConcatMember)

        current_member = @all.find { |m| m.type == new_member.type && m.value == new_member.value }
        return false if current_member.nil?

        current_member.remove!

        true
      end
    end
  end
end
