# frozen_string_literal: true

module Zm
  module Client
    # class factory [appointments]
    class AppointmentsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        super(parent, json)
        @json_item_key = :appt
      end

      def make
        return [] if json_items.nil?

        json_items.map do |entry|
          AppointmentJsnsInitializer.new(@parent, entry).create
        end
      end
    end
  end
end
