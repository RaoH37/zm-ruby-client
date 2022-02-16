# frozen_string_literal: true

module Zm
  module Client
    module Base
      # class for account object jsns builder
      class BaseJsnsBuilder

        def initialize(item)
          @item = item
        end

        def to_delete
          { id: @item.id }
        end
      end
    end
  end
end
