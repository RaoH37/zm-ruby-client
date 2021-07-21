# frozen_string_literal: true

module Zm
  module Client
    # class factory [resources]
    class ResourcesBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @child_class = Resource
      end

      # def make
      #   return [] if json_items.nil?
      #
      #   json_items.map do |entry|
      #     resource = Resource.new(@parent)
      #     resource.init_from_json(entry)
      #     resource
      #   end
      # end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:calresource]
      end
    end
  end
end
