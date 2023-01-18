# frozen_string_literal: true

require 'addressable/uri'

module Zm
  module Client
    module Utils
      class << self
        def format_url_params(hash)
          uri = Addressable::URI.new
          uri.query_values = hash
          uri.query
        end
      end
    end
  end
end
