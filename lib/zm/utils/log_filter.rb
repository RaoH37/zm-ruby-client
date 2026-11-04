# frozen_string_literal: true

module Zm
  module Utils
    # mask credentials and tokens in logged SOAP and HTTP payloads
    module LogFilter
      FILTERED = '[FILTERED]'
      JSON_STRING = '"(?:[^"\\\\]|\\\\.)*"'

      JSON_SECRET_KEYS = [
        '"(?:password|newPassword|authToken)":',
        '"(?:authToken|preauth)":\\[?\\{[^}]*?"_content":',
        '"n":"(?:userPassword|zimbraPreAuthKey)","_content":'
      ].freeze
      COOKIE_SECRET = 'ZM_(?:ADMIN_)?AUTH_TOKEN='

      PATTERNS = [
        *JSON_SECRET_KEYS.map { |key| [/(#{key})#{JSON_STRING}/, "\\1\"#{FILTERED}\""] },
        [/(#{COOKIE_SECRET})[^;\s"]+/o, "\\1#{FILTERED}"]
      ].freeze

      FILTER_REGEX = /((?:#{JSON_SECRET_KEYS.join('|')})")(?:[^"\\]|\\.)*(")|(#{COOKIE_SECRET})[^;\s"]+/o
      FILTER_REPLACEMENT = "\\1\\3#{FILTERED}\\2".freeze

      module_function

      def filter(str)
        return str if str.nil?

        str.gsub(FILTER_REGEX, FILTER_REPLACEMENT)
      end

      def apply(formatter)
        PATTERNS.each { |pattern, replacement| formatter.filter(pattern, replacement) }
      end
    end
  end
end
