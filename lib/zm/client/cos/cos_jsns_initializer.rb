# frozen_string_literal: true

module Zm
  module Client
    # class for initialize cos
    class CosJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Cos.new(parent)

          update(item, json)
        end

        def update(item, json)
          item = super(item, json)

          item.zimbraMailHostPool = [item.zimbraMailHostPool] if item.zimbraMailHostPool.is_a?(String)

          item
        end
      end
    end
  end
end
