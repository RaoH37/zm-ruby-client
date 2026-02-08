# frozen_string_literal: true

module Zm
  module Client
    class Backup < Base::Object
      FULL = 'full'
      INCREMENTAL = 'incremental'

      attr_accessor :label, :type, :aborted, :start, :end, :minRedoSeq, :maxRedoSeq, :live, :accounts

      alias name label

      def server
        parent
      end

      def start_at
        return @start_at if defined? @start_at

        @start_at = Time.at(@start / 1000)
      rescue StandardError
        nil
      end

      def end_at
        return @end_at if defined? @end_at

        @end_at = Time.at(@end / 1000)
      rescue StandardError
        nil
      end

      def full?
        @type == FULL
      end

      def incremental?
        @type == INCREMENTAL
      end
    end
  end
end
