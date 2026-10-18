# frozen_string_literal: true

module Zm
  module Client
    # class for initialize distribution list
    class DistributionListJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def klass = DistributionList

        def update(item, json)
          super

          unless item.zimbraMailForwardingAddress.is_a?(Array)
            item.zimbraMailForwardingAddress = [item.zimbraMailForwardingAddress]
            item.zimbraMailForwardingAddress.compact!
          end

          update_members(item, json)
          update_owners(item, json)

          item
        end

        private

        def update_members(item, json)
          if json[:dlm].is_a?(Array)
            item.members.all = json[:dlm].filter_map { |a| a[:_content] }
          elsif !item.zimbraMailForwardingAddress.empty?
            item.members.all = item.zimbraMailForwardingAddress
          end
        end

        def update_owners(item, json)
          return unless json[:owners].is_a?(Array)

          item.owners.all = json[:owners].first[:owner].filter_map { |a| a[:name] }
        end
      end
    end
  end
end
