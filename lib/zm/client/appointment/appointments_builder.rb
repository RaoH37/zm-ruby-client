# frozen_string_literal: true

module Zm
  module Client
    # class factory [appointments]
    class AppointmentsBuilder < Base::ObjectsBuilder
      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root.map do |s|
          # Appointment.new(@parent, s)
          # Appointment.new(@parent)
          AppointmentJsnsInitializer.new(@parent, s).create
        end
      end

      def ids
        root.map { |s| s[:id] }
      end

      def root
        root = @json[:Body][:SearchResponse][:appt]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root
      end
    end
  end
end
