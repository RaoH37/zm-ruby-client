# frozen_string_literal: true

module Zm
  module Client
    class LdapFilter
      def initialize(base_filter = nil)
        @base_filter = base_filter
        @parts = []
      end

      def add(filter)
        if filter.is_a?(String) && !filter.empty?
          @parts << filter
        elsif filter.is_a?(Hash)
          @parts += filter.map { |k, v| "(#{k}=#{v})" }
        end
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
    end
  end
end
