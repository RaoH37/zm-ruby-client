# frozen_string_literal: true

module Zm
  module Client
    class LdapFilter
      include Zm::Inspector

      def initialize(base_filter = nil)
        @base_filter = base_filter
        @parts = []
      end

      def add(filter)
        new_filter = stringify_filter(filter)
        return false if new_filter.nil? || @parts.include?(new_filter)

        @parts << new_filter
        true
      end

      def clear
        @parts.clear
      end

      def join
        arr = @parts.dup
        arr.unshift(@base_filter) unless @base_filter.nil?

        return arr.first if arr.length <= 1

        "(&#{arr.join})"
      end

      private

      def stringify_filter(filter)
        return nil if !filter.is_a?(String) && !filter.is_a?(Hash)

        return filter.map { |k, v| "(#{k}=#{v})" }.join if filter.is_a?(Hash)

        new_filter = filter.strip
        return nil if new_filter.empty?

        new_filter
      end
    end
  end
end
