# frozen_string_literal: true

require 'zm/client/mta_queue_item'

module Zm
  module Client
    class MtaQueue < Base::Object
      include HasSoapAdminConnector

      attr_accessor :name, :n

      alias nb_items n

      def server
        @parent
      end

      def items
        return @items if defined? @items

        @items = MtaQueueItemsCollection.new self
      end

      def hold!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::HOLD, ids))
      end

      def release!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::RELEASE, ids))
      end

      def delete!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::DELETE, ids))
      end

      def requeue!(ids)
        sac.invoke(jsns_builder.to_jsns(Zm::Client::MtaQueueAction::REQUEUE, ids))
      end

      private

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = MtaQueueJsnsBuilder.new(self)
      end
    end
  end
end
