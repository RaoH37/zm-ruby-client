# frozen_string_literal: true

module Zm
  module Client
    # class factory [appointments]
    class AppointmentsBuilder < Base::ObjectsBuilder
      def initialize(account, json)
        @account = account
        @json = json
      end

      def make
        root = @json[:Body][:SearchResponse][:appt]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)

        root.map do |s|
          Appointment.new(@parent, s)
        end
      end
    end
  end
end
