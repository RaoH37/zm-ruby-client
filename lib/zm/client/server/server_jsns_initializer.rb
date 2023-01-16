# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class ServerJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Server.new(parent)

          update(item, json)
        end
      end
    end
  end
end
