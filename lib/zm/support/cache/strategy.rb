# frozen_string_literal: true

module Zm
  module Support
    module Cache
      class Strategy
        def initialize(expires_in: 300)
          @expires_in = expires_in
        end
      end
    end
  end
end
