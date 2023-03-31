# frozen_string_literal: true

module Zm
  module Client
    # Collection MtaQueues
    class MtaQueueItemsCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def mta_queue
        parent
      end

      def server
        mta_queue.parent
      end

      def all
        @all ||= all!
      end

      def all!
        build_response
      end

      def where(fields)
        @fields = fields
        self
      end

      def fromdomain(value)
        @fields[:fromdomain] = value
        self
      end

      def todomain(value)
        @fields[:todomain] = value
        self
      end

      def ids
        all.map(&:id)
      end

      def do_action(action_name)
        sac.mail_queue_action(server.name, mta_queue.name, action_name, ids)
      end

      def hold!
        do_action(Zm::Client::MtaQueueAction::HOLD)
      end

      def release!
        do_action(Zm::Client::MtaQueueAction::RELEASE)
      end

      def delete!
        do_action(Zm::Client::MtaQueueAction::DELETE)
      end

      def requeue!
        do_action(Zm::Client::MtaQueueAction::REQUEUE)
      end

      def method_missing(method, *args, &block)
        if METHODS_MISSING_LIST.include?(method)
          build_response.send(method, *args, &block)
        else
          super
        end
      end

      def respond_to_missing?(method, *)
        METHODS_MISSING_LIST.include?(method) || super
      end

      private

      def make_query
        json = sac.get_mail_queue(@parent.parent.name, @parent.name, @offset, @limit, @fields)
        reset_query_params
        json
      end

      def build_response
        MtaQueueItemsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @fields = {}
      end
    end
  end
end
