# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class MtaQueueItemJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = MtaQueueItem.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.size = json[:size]
          item.fromdomain = json[:fromdomain]
          item.id = json[:id]
          item.reason = json[:reason]
          item.time = json[:time].to_i
          item.to = json[:to] ? json[:to].split(',') : []
          item.addr = json[:addr]
          item.filter = json[:filter]
          item.host = json[:host]
          item.from = json[:from]
          item.todomain = json[:todomain] ? json[:todomain].split(',') : []
          item.received = json[:received]

          item
        end
      end
    end
  end
end
