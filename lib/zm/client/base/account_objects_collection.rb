# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Collection AccountObjectsCollection
      class AccountObjectsCollection < ObjectsCollection
        def initialize(parent)
          @parent = parent
        end
      end
    end
  end
end
