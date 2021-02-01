# frozen_string_literal: true

module Zm
  # module client Zm::Client
  module Client
    def self.gem_version
      Gem::Version.new VERSION::STRING
    end

    module VERSION
      MAJOR = 0
      MINOR = 3
      TINY  = 3

      STRING = [MAJOR, MINOR, TINY].compact.join('.')
    end
  end
end
