# frozen_string_literal: true

module Zm
  module Client
    # collection of appointments
    class AppointmentsCollection < Base::ObjectsCollection
      METHODS_MISSING_LIST = %i[select each map length].to_set.freeze

      def initialize(parent)
        @parent = parent
        @start_at = nil
        @end_at = nil
        @query = nil
      end

      def new
        appointment = Appointment.new(@parent)
        yield(appointment) if block_given?
        appointment
      end

      def where(start_at = nil, end_at = nil, query = nil)
        @start_at = start_at
        @end_at = end_at
        @query = query
        self
      end

      private

      def build_response
        rep = @parent.sacc.search(@parent.token, 'appointment', @offset, @limit, 'dateAsc', @query, build_options)
        ab = AppointmentsBuilder.new @parent, rep
        ab.make
      end

      def build_options
        return nil if !@start_at.is_a?(Time) && !@end_at.is_a?(Time)

        {
            calExpandInstStart: (@start_at.to_f * 1000).to_i,
            calExpandInstEnd: (@end_at.to_f * 1000).to_i
        }
      end

      def reset_query_params
        super
        @start_at = nil
        @end_at = nil
        @query = nil
      end
    end
  end
end
