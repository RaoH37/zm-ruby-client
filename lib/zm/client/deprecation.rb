# frozen_string_literal: true

module Zm
  module Client
    # prints a deprecation warning once per deprecated name
    module Deprecation
      MUTEX = Mutex.new

      class << self
        def warn_once(name, advice)
          return unless MUTEX.synchronize { warned.add?(name) }

          warn("#{name} is deprecated and will be removed in 4.0, #{advice}", uplevel: 2)
        end

        private

        def warned
          @warned ||= Set.new
        end
      end
    end
  end
end
