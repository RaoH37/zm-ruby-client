# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class MtaQueueJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = MtaQueue.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.n = json[:n]
          item.name = json[:name]

          item
        end
      end
    end
  end
end
