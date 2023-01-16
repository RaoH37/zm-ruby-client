# frozen_string_literal: true

module Zm
  module Client
    # class for initialize domain
    class DomainJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Domain.new(parent)

          update(item, json)
        end
      end
    end
  end
end
