# frozen_string_literal: true

module Zm
  module Client
    # class for initialize distribution list
    class DistributionListJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = DistributionList.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]

          formatted_json(json).each do |k, v|
            valorise(item, k, v)
          end

          item.members.all = json[:dlm].map { |a| a[:_content] }.compact if json[:dlm].is_a?(Array)
          item.owners.all = json[:owners].first[:owner].map { |a| a[:name] }.compact if json[:owners].is_a?(Array)

          # todo: ajouter dans les members les valeurs de zimbraMailForwardingAddress si members.all.empty?

          item
        end
      end
    end
  end
end
