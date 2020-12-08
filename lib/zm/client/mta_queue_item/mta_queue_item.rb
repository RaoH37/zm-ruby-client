# frozen_string_literal: true

module Zm
  module Client
    class MtaQueueItem < Base::AdminObject
      attr_reader :name, :n

      INSTANCE_VARIABLE_KEYS = %i[size fromdomain id reason time to addr filter host from todomain received]
      attr_reader *INSTANCE_VARIABLE_KEYS

      def to_h
        hashmap = Hash[INSTANCE_VARIABLE_KEYS.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def init_from_json(json)
        @size = json[:size]
        @fromdomain = json[:fromdomain]
        @id = json[:id]
        @reason = json[:reason]
        @time = json[:time]
        @to = json[:to]
        @addr = json[:addr]
        @filter = json[:filter]
        @host = json[:host]
        @from = json[:from]
        @todomain = json[:todomain]
        @received = json[:received]
      end
    end
  end
end
