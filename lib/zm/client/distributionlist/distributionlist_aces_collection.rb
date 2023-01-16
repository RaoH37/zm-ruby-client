# frozen_string_literal: true

module Zm
  module Client
    DistributionListAce = Struct.new(:zimbra_id, :type, :right)

    # Collection Account Aliases
    class DistributionListAcesCollection
      def initialize(parent)
        @parent = parent
        @memorized = []
        build_aces
      end

      def all
        @memorized
      end

      private

      def build_aces
        return if @parent.zimbraACE.nil?

        zimbra_aces = @parent.zimbraACE.is_a?(Array) ? @parent.zimbraACE : [@parent.zimbraACE]

        @memorized = zimbra_aces.map do |str|
          parts = str.split(/\s+/)
          DistributionListAce.new(parts[0], parts[1], parts[2])
        end
      end
    end
  end
end
