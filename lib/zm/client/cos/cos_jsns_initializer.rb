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
      end
    end
  end
end
