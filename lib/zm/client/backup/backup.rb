# frozen_string_literal: true

module Zm
  module Client
    class Backup < Base::AdminObject
      attr_accessor :label, :type, :aborted, :start, :end, :minRedoSeq, :maxRedoSeq, :live, :accounts

      alias name label

      def server
        parent
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

      # def init_from_json(json)
      #   @label = json[:label]
      #   @type = json[:type]
      #   @aborted = json[:aborted]
      #   @start = json[:start].to_i
      #   @end = json[:end].to_i
      #   @minRedoSeq = json[:minRedoSeq]
      #   @maxRedoSeq = json[:maxRedoSeq]
      #   @live = json[:live]
      #   @accounts = json[:accounts]
      # end
    end
  end
end
