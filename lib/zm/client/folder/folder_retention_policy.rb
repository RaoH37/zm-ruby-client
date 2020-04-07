# frozen_string_literal: true

module Zm
  module Client
    # class for account folder retention policy
    class FolderRetentionPolicy < Base::AccountObject

      class << self
        def create_by_json(parent, policy, json)
          frp = self.new(parent)
          frp.init_from_json(policy, json)
          frp
        end
      end

      attr_accessor :type, :policy, :lifetime

      def keep?
        @policy == :keep
      end

      def purge?
        @policy == :purge
      end

      def init_from_json(policy, json)
        return if json.empty? || json[:policy].nil?

        @policy = policy
        @type = json[:policy].first[:type]
        @lifetime = json[:policy].first[:lifetime]
      end

      def to_h
        # :purge=>[{:policy=>[{:lifetime=>"366d", :type=>"user"}]}]
        {
          @policy => {
            policy: {
              lifetime: @lifetime,
              type: @type
            }
          }
        }
      end

    end
  end
end
