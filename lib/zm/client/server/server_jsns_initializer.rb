# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class ServerJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def klass = Server
      end
    end
  end
end
