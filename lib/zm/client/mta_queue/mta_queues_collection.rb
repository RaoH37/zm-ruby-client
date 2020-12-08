# frozen_string_literal: true

module Zm
  module Client
    # Collection MtaQueues
    class MtaQueuesCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
        @dynamic_methods = []
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
        sac.get_mail_queue_info(@parent.name)
      end

      def build_response
        queues = MtaQueuesBuilder.new(@parent, make_query).make
        clear_dynamic_methods

        queues.each do |queue|
          s_name = "@#{queue.name}"
          instance_variable_set(s_name, queue)
          self.class.attr_reader queue.name
          @dynamic_methods << s_name
        end
        queues
      end

      def clear_dynamic_methods
        return if @dynamic_methods.empty?

        @dynamic_methods.each do |name|
          remove_instance_variable(name) if instance_variable_get(name)
        end
      end
    end
  end
end
