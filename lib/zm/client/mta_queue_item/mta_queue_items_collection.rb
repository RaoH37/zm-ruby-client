# frozen_string_literal: true

module Zm
  module Client
    # Collection MtaQueues
    class MtaQueueItemsCollection < Base::ObjectsCollection
      attr_reader :offset, :limit, :fields

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

      private

      def make_query
        json = sac.invoke(jsns_builder.to_list)

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

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = MtaQueueJsnsBuilder.new(self)
      end
    end
  end
end
