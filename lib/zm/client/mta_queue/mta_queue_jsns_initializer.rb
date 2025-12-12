# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class MtaQueueJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def klass = MtaQueue

        def update(item, json)
          item.n = json.delete(:n)
          item.name = json.delete(:name)

          item
        end
      end
    end
  end
end
