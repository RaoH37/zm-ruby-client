# frozen_string_literal: true

module Zm
  module Client
    class MtaQueueItem < Base::AdminObject
      INSTANCE_VARIABLE_KEYS = %i[size fromdomain id reason time to addr filter host from todomain received].freeze

      attr_reader :name, :n, *INSTANCE_VARIABLE_KEYS

      def mta_queue
        parent
      end

      def server
        mta_queue.parent
      end

      def to_h
        hashmap = Hash[INSTANCE_VARIABLE_KEYS.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def sent_at
        @sent_at ||= Time.at(@time / 1000)
      rescue StandardError => e
        nil
      end

      def hold!
        sac.mail_queue_action(server.name, mta_queue.name, Zm::Client::MtaQueueAction::HOLD, @id)
      end

      def init_from_json(json)
        @size = json[:size]
        @fromdomain = json[:fromdomain]
        @id = json[:id]
        @reason = json[:reason]
        @time = json[:time].to_i
        @to = json[:to] ? json[:to].split(',') : []
        @addr = json[:addr]
        @filter = json[:filter]
        @host = json[:host]
        @from = json[:from]
        @todomain = json[:todomain] ? json[:todomain].split(',') : []
        @received = json[:received]
      end
    end
  end
end
