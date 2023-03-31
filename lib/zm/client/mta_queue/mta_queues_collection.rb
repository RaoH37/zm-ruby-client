# frozen_string_literal: true

module Zm
  module Client
    # Collection MtaQueues
    class MtaQueuesCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def all
        @all ||= all!
      end

      def all!
        build_response
      end

      def defaults
        @all || defaults!
      end

      def defaults!
        # queues = []
        Zm::Client::MtaQueueName::ALL.each do |queue_name|
          queue = MtaQueue.new(@parent)
          queue.name = queue_name
          set_dynamic_queue_method(queue)
          @queues_h[queue_name] = queue
          # queues << queue
        end
        # @all = queues
        @all = @queues_h.values
      end

      def find(queue_name)
        raise ZmError, 'Unknown queue name' unless Zm::Client::MtaQueueName::ALL.include?(queue_name)
        all! if @queues_h.empty?
        @queues_h[queue_name]
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
        sac.get_mail_queue_info(@parent.name)
      end

      def build_response
        queues = MtaQueuesBuilder.new(@parent, make_query).make
        clear_dynamic_methods

        queues.each do |queue|
          set_dynamic_queue_method(queue)
          @queues_h[queue.name] = queue
        end
        queues
      end

      def set_dynamic_queue_method(queue)
        s_name = "@#{queue.name}"
        instance_variable_set(s_name, queue)
        self.class.attr_reader queue.name
        @dynamic_methods << s_name
      end

      def clear_dynamic_methods
        return if @dynamic_methods.empty?

        @dynamic_methods.each do |name|
          remove_instance_variable(name) if instance_variable_get(name)
        end
      end

      def reset_query_params
        @dynamic_methods = []
        @queues_h = {}
      end
    end
  end
end
