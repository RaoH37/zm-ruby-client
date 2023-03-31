# frozen_string_literal: true

require 'zm/client/mta_queue_item'

module Zm
  module Client
    class MtaQueue < Base::AdminObject
      attr_accessor :name, :n

      alias nb_items n

      def server
        @parent
      end

      def items
        @items ||= MtaQueueItemsCollection.new self
      end

      def hold!(ids)
        sac.jsns_request(:MailQueueActionRequest, jsns_builder.to_jsns(Zm::Client::MtaQueueAction::HOLD, ids))
      end

      def release!(ids)
        sac.jsns_request(:MailQueueActionRequest, jsns_builder.to_jsns(Zm::Client::MtaQueueAction::RELEASE, ids))
      end

      def delete!(ids)
        sac.jsns_request(:MailQueueActionRequest, jsns_builder.to_jsns(Zm::Client::MtaQueueAction::DELETE, ids))
      end

      def requeue!(ids)
        sac.jsns_request(:MailQueueActionRequest, jsns_builder.to_jsns(Zm::Client::MtaQueueAction::REQUEUE, ids))
      end

      private

      def jsns_builder
        @jsns_builder ||= MtaQueueJsnsBuilder.new(self)
      end
    end
  end
end
