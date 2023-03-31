# frozen_string_literal: true

require 'zm/client/mta_queue_item'

module Zm
  module Client
    class MtaQueue < Base::AdminObject
      attr_reader :name, :n

      alias nb_items n

      def server
        parent
      end

      def to_h
        hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def to_s
        to_h.to_s
      end

      def all_instance_variable_keys
        %w[name n]
      end

      def items
        @items ||= MtaQueueItemsCollection.new self
      end

      def do_action(action_name, ids)
        sac.mail_queue_action(parent.name, name, action_name, ids)
      end

      def hold!(ids)
        do_action(Zm::Client::MtaQueueAction::HOLD, ids)
      end

      def release!(ids)
        do_action(Zm::Client::MtaQueueAction::RELEASE, ids)
      end

      def delete!(ids)
        do_action(Zm::Client::MtaQueueAction::DELETE, ids)
      end

      def requeue!(ids)
        do_action(Zm::Client::MtaQueueAction::REQUEUE, ids)
      end

      def init_from_json(json)
        @name = json[:name]
        @n = json[:n].to_i
      end
    end
  end
end
