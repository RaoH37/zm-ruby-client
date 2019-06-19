# frozen_string_literal: true

module Zm
  module Client
    # class factory [coses]
    class CosesBuilder < Base::ObjectsBuilder
      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          cos = Cos.new(@parent)
          cos.init_from_json(entry)
          cos
        end
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:cos]
      end
    end
  end
end
