# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account ace
    class AceJsnsInitializer
      class << self
        def create(parent, json)
          item = Ace.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.instance_variable_set(:@zid, json[:zid])
          item.instance_variable_set(:@gt, json[:gt])
          item.instance_variable_set(:@right, json[:right])
          item.instance_variable_set(:@d, json[:d])

          item
        end
      end
    end
  end
end
