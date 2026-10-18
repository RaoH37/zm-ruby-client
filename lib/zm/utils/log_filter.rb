# frozen_string_literal: true

module Zm
  module Utils
    # mask credentials and tokens in logged SOAP and HTTP payloads
    module LogFilter
      FILTERED = '[FILTERED]'
      JSON_STRING = '"(?:[^"\\\\]|\\\\.)*"'

      PATTERNS = [
        [/("(?:password|newPassword|authToken)":)#{JSON_STRING}/o, "\\1\"#{FILTERED}\""],
        [/("(?:authToken|preauth)":\[?\{[^}]*?"_content":)#{JSON_STRING}/o, "\\1\"#{FILTERED}\""],
        [/("n":"(?:userPassword|zimbraPreAuthKey)","_content":)#{JSON_STRING}/o, "\\1\"#{FILTERED}\""],
        [/(ZM_(?:ADMIN_)?AUTH_TOKEN=)[^;\s"]+/, "\\1#{FILTERED}"]
      ].freeze

      module_function

      def filter(str)
        return str if str.nil?

        PATTERNS.inject(str) { |result, (pattern, replacement)| result.gsub(pattern, replacement) }
      end

      def apply(formatter)
        PATTERNS.each { |pattern, replacement| formatter.filter(pattern, replacement) }
      end
    end
  end
end
