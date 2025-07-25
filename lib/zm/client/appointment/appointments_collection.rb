# frozen_string_literal: true

module Zm
  module Client
    # collection of appointments
    class AppointmentsCollection < Base::AccountSearchObjectsCollection
      def initialize(parent)
        super(parent)
        @child_class = Appointment
        @builder_class = AppointmentsBuilder
        @type = SoapConstants::APPOINTMENT
        @sort_by = SoapConstants::DATE_ASC
      end

      def find(id)
        jsns = { m: { id: id, html: 1 } }

        soap_request = SoapElement.mail(SoapMailConstants::GET_MSG_REQUEST).add_attributes(jsns)
        rep = @parent.soap_connector.invoke(soap_request)
        entry = rep[:GetMsgResponse][:m].first

        AppointmentJsnsInitializer.new(@parent, entry).create
      end

      def find_each(offset: 0, limit: 500, &block)
        (1970..(Time.now.year + 10)).each do |year|
          @start_at = Time.new(year, 1, 1)
          @end_at = Time.new(year, 12, 31)
          @more = true
          @offset = offset
          @limit = limit

          while @more
            build_response.each { |item| block.call(item) }
            @offset += @limit
          end
        end
      end
    end
  end
end
