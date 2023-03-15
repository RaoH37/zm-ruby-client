# frozen_string_literal: true

require 'addressable/uri'

module Zm
  module Client
    module Utils
      A_ARRAY_PROC = ->(i) { i.last.is_a?(Array) ? i.last.map { |j| [i.first, j] } : [i] }
      A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }
      ARROW = '@'
      EQUALS = '='

      class << self
        def format_url_params(hash)
          uri = Addressable::URI.new
          uri.query_values = hash
          uri.query
        end

        # TODO: chercher - remplacer toutes les occurences dans le code
        def arrow_name(name)
          return name if name.to_s.start_with?(ARROW)

          "#{ARROW}#{name}"
        end

        def arrow_name_sym(name)
          arrow_name(name).to_sym
        end

        def equals_name(name)
          return name if name.to_s.end_with?(EQUALS)

          "#{name}#{EQUALS}"
        end
      end
    end
  end
end
