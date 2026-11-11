# frozen_string_literal: true

module Zm
  module Client
    # class for account folder retention policy
    class FolderRetentionPolicy
      attr_accessor :type, :policy, :lifetime

      def initialize(parent, policy, lifetime, type)
        @parent = parent
        @policy = policy
        @lifetime = lifetime
        @type = type
      end

      def keep?
        @policy.to_sym == :keep
      end

      def purge?
        @policy.to_sym == :purge
      end
    end
  end
end
