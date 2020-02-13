# frozen_string_literal: true

module Zm
  module Client
    # class factory [folders]
    class SignaturesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root = @json[:Body][:GetSignaturesResponse][:signature]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)

        root.map do |s|
          signature = Signature.new(@parent)
          signature.init_from_json(s)
          signature
        end
      end
    end
  end
end
