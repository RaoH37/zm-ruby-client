# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class ServerJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          Server.new(parent).tap do |item|
            update(item, json)
          end
        end
      end
    end
  end
end
