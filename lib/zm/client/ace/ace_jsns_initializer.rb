# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account ace
    class AceJsnsInitializer
      class << self
        def create(parent, json)
          Ace.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.zid = json.delete(:zid)
          item.gt = json.delete(:gt)
          item.right = json.delete(:right)
          item.d = json.delete(:d)

          item
        end
      end
    end
  end
end
