# frozen_string_literal: true

module Zm
  module Client
    class MtaQueueItem < Base::AdminObject
      attr_accessor :name, :n, :size, :fromdomain, :id, :reason, :time, :to, :addr, :filter, :host, :from, :todomain,
                    :received

      def mta_queue
        parent
      end

      def server
        mta_queue.parent
      end

      def sent_at
        @sent_at ||= Time.at(@time / 1000)
      rescue StandardError => e
        nil
      end
    end
  end
end
