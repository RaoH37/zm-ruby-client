# frozen_string_literal: true

module Zm
  module Client
    module MtaQueueName
      INCOMING = 'incoming'
      DEFERRED = 'deferred'
      CORRUPT = 'corrupt'
      ACTIVE = 'active'
      HOLD = 'hold'
      ALL = [INCOMING, DEFERRED, CORRUPT, ACTIVE, HOLD].freeze
    end
  end
end
