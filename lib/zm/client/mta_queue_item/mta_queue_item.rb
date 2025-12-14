# frozen_string_literal: true

module Zm
  module Client
    class MtaQueueItem < Base::Object
      attr_accessor :name, :n, :size, :fromdomain, :id, :reason, :time, :to, :addr,
                    :filter, :host, :from, :todomain, :received

      def mta_queue
        parent
      end

      def server
        mta_queue.parent
      end

      def sent_at
        return @sent_at if defined? @sent_at

        @sent_at = Time.at(@time / 1000)
      rescue StandardError
        nil
      end
    end
  end
end
