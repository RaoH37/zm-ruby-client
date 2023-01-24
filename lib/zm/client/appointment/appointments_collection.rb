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

      def find_each
        @all = []
        (1970..(Time.now.year + 10)).each do |year|
          @start_at = Time.new(year, 1, 1)
          @end_at = Time.new(year, 12, 31)
          @more = true
          @offset = 0
          @limit = 500

          while @more
            @all += build_response
            @offset += @limit
          end
        end
        @all
      end
    end
  end
end
