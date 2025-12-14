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
        def format_email(email)
          email.strip!
          email.downcase!
          email
        end

        def format_url_path(path)
          Addressable::URI.escape path
        end

        def format_url_params(hash)
          uri = Addressable::URI.new
          uri.query_values = hash
          uri.query
        end

        # TODO: chercher - remplacer toutes les occurrences dans le code
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

        def map_format(array, klass, method_name)
          array.map! do |item|
            if item.is_a?(klass)
              item
            elsif item.respond_to?(method_name)
              item.name
            end
          end
          array.compact!
          array
        end
      end
    end
  end
end
