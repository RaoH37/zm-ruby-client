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
    end
  end
end
