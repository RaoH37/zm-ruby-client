# frozen_string_literal: true

module Zm
  module Client
    # class for folder retention policies collection
    class FolderRetentionPoliciesCollection
      include MissingMethodStaticCollection

      def initialize(parent)
        @parent = parent
        @all = []
      end

      def new(policy, lifetime, type)
        FolderRetentionPolicy.new(self, policy, lifetime, type)
      end

      def create(policy, lifetime, type)
        frp = new(policy, lifetime, type)
        add(frp)
      end

      def add(retention_policy)
        @all << retention_policy
      end

      def save!
        @parent.sacc.invoke(jsns_builder.to_retentionpolicy)
        true
      end

      private

      def jsns_builder
        @jsns_builder ||= FolderJsnsBuilder.new(@parent)
      end
    end
  end
end
