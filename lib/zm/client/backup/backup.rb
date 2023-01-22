# frozen_string_literal: true

module Zm
  module Client
    class Backup < Base::AdminObject
      INSTANCE_VARIABLE_KEYS = %i[label type aborted start end minRedoSeq maxRedoSeq live accounts].freeze

      attr_reader(*INSTANCE_VARIABLE_KEYS)

      alias name label

      def server
        parent
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      # def to_h
      #   hashmap = Hash[INSTANCE_VARIABLE_KEYS.map { |key| [key, instance_variable_get(arrow_name(key))] }]
      #   hashmap.delete_if { |_, v| v.nil? }
      #   hashmap
      # end

      def to_s
        to_h.to_s
      end

      def start_at
        @start_at ||= Time.at(@start / 1000)
      rescue StandardError => e
        nil
      end

      def end_at
        @end_at ||= Time.at(@end / 1000)
      rescue StandardError => e
        nil
      end

      def full?
        @type == Zm::Client::BackupTypes::FULL
      end

      def incremental?
        @type == Zm::Client::BackupTypes::INCREMENTAL
      end

      def init_from_json(json)
        @label = json[:label]
        @type = json[:type]
        @aborted = json[:aborted]
        @start = json[:start].to_i
        @end = json[:end].to_i
        @minRedoSeq = json[:minRedoSeq]
        @maxRedoSeq = json[:maxRedoSeq]
        @live = json[:live]
        @accounts = json[:accounts]
      end
    end
  end
end
