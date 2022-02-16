# frozen_string_literal: true

module Zm
  module Client
    # collection of appointments
    class AppointmentsCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super(parent)
        @child_class = Appointment
        @builder_class = AppointmentsBuilder
        @type = 'appointment'
        @sort_by = 'dateAsc'
      end

      def find(id)
        rep = @parent.sacc.get_msg(@parent.token, id)
        entry = rep[:Body][:GetMsgResponse][:m].first
        AppointmentJsnsInitializer.new(@parent, entry).create
      end
    end
  end
end
