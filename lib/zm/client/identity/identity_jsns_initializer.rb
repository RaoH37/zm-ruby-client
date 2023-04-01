# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account identity
    class IdentityJsnsInitializer
      class << self
        def create(parent, json)
          item = Identity.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]

          return item if json[:_attrs].nil? || json[:_attrs].empty?

          json[:_attrs].each do |k, v|
            m = Utils.equals_name(k)
            item.send(m, v) if item.respond_to?(m)
          end

          item
        end
      end
    end
  end
end
