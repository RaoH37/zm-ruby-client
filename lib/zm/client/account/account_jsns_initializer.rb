# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class AccountJsnsInitializer
      class << self
        def create(parent, json)
          item = Account.new(parent)

          update(item, json)
        end

        def update(item, json)

          attr_types_h = item.parent.zimbra_attributes.all_account_attr_types_h

          puts attr_types_h

          item.id    = json[:id]
          item.name  = json[:name]

          json[:a].reject! { |n| n[:n].nil? }
          json_map = Hash[json[:a].map { |n| [n[:n], n[:_content]] }].freeze

          puts json_map

          # item.parent.zimbra_attributes.all_account_attrs.each do |attr|
          #   if attr.type.nil?
          #     # p attr
          #   else
          #     json_field = json_map[attr.name]
          #     puts json_field unless json_field.nil?
          #   end
          # end

          item.init_from_json(json)

          item
        end
      end
    end
  end
end
