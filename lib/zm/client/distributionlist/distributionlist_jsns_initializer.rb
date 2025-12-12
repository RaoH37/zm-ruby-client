# frozen_string_literal: true

module Zm
  module Client
    # class for initialize distribution list
    class DistributionListJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          DistributionList.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.name = json.delete(:name)

          formatted_json(json).each do |k, v|
            valorise(item, k, v)
          end

          unless item.zimbraMailForwardingAddress.is_a?(Array)
            item.zimbraMailForwardingAddress = [item.zimbraMailForwardingAddress]
            item.zimbraMailForwardingAddress.compact!
          end

          if json[:dlm].is_a?(Array)
            item.members.all = json[:dlm].map { |a| a[:_content] }.compact
          elsif !item.zimbraMailForwardingAddress.empty?
            item.members.all = item.zimbraMailForwardingAddress
          end

          item.owners.all = json[:owners].first[:owner].map { |a| a[:name] }.compact if json[:owners].is_a?(Array)

          item
        end
      end
    end
  end
end
