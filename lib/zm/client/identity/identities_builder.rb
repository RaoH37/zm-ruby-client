# frozen_string_literal: true

module Zm
  module Client
    # class factory [identitys]
    class IdentitiesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root = @json[:Body][:GetIdentitiesResponse][:identity]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root.map do |s|
          identity = Identity.new(@parent)
          identity.init_from_json(s)
          identity
        end
      end
    end
  end
end
