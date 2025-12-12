# frozen_string_literal: true

module Zm
  module Client
    # class for initialize cos
    class CosJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def klass = Cos

        def update(item, json)
          item = super(item, json)

          case item.zimbraMailHostPool
          when String
            item.zimbraMailHostPool = [item.zimbraMailHostPool]
          when NilClass
            item.zimbraMailHostPool = []
          end

          item
        end
      end
    end
  end
end
