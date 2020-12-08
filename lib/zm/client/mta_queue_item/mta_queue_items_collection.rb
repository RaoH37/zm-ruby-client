# frozen_string_literal: true

module Zm
  module Client
    # Collection MtaQueues
    class MtaQueueItemsCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
      end

      def all
        @all ||= all!
      end

      def all!
        build_response
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
        sac.get_mail_queue(@parent.parent.name, @parent.name)
      end

      def build_response
        MtaQueueItemsBuilder.new(@parent, make_query).make
      end
    end
  end
end
