# frozen_string_literal: true

module Zm
  module Client
    # class factory [aces]
    class AcesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root = @json[:Body][:GetRightsResponse][:ace]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root.map do |s|
          ace = Ace.new(@parent)
          ace.init_from_json(s)
          ace
        end
      end
    end
  end
end
