# frozen_string_literal: true

require 'zm/client/mta_queue_item'

module Zm
  module Client
    class MtaQueue < Base::AdminObject
      attr_reader :name, :n

      alias nb_items n

      def to_h
        hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def all_instance_variable_keys
        %w[name n]
      end

      def items
        @items ||= items!
      end

      def items!
        MtaQueueItemsCollection.new self
      end

      def init_from_json(json)
        @name = json[:name]
        @n = json[:n].to_i
      end
    end
  end
end
