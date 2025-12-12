# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class MtaQueueJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          MtaQueue.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.n = json.delete(:n)
          item.name = json.delete(:name)

          item
        end
      end
    end
  end
end
