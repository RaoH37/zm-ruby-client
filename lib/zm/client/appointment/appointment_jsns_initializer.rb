# frozen_string_literal: true

module Zm
  module Client
    # class for account appointment
    class AppointmentJsnsInitializer

      attr_accessor :appointment

      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def update
        return false if @appointment.nil?

        @appointment.calItemId = @json[:calItemId]
        @appointment.apptId = @json[:apptId]
        @appointment.invId = @json[:invId]
        @appointment.id = @json[:invId]
        @appointment.rev = @json[:rev]

        true
      end

      def create
        @appointment ||= Appointment.new(@parent)

        @appointment.id = @json[:id]
        @appointment.tn = @json[:tn]
        @appointment.l = @json[:l].to_i
        @appointment.uid = @json[:uid]

        if inv.nil?
          init_from_search
        else
          init_from_inv
        end

        @appointment
      end

      def inv
        @inv ||= @json[:inv]&.first
      end

      def init_from_search
        @appointment.organizer = Zm::Client::Appointment::Organizer.new(search_organizer_name) unless search_organizer_name.nil?
        @appointment.name = @json[:name]
        @appointment.id = @json[:invId]
        @appointment.desc = @json[:fr]
        @appointment.allDay = @json[:allDay] unless @json[:allDay].nil?
        search_make_date
      end

      def init_from_inv
        @appointment.uid = comp[:uid]
        @appointment.fb = comp[:fb]
        @appointment.transp = comp[:transp]
        @appointment.timezone = tz[:id]
        @appointment.name = comp[:name]
        @appointment.desc = comp[:desc].first[:_content] unless comp[:desc].nil?
        @appointment.apptId = comp[:apptId]
        @appointment.allDay = comp[:allDay] unless comp[:allDay].nil?

        @appointment.organizer = Zm::Client::Appointment::Organizer.new(comp_organizer_name) unless comp_organizer_name.nil?

        attendees.each do |attendee|
          @appointment.attendees.add(Zm::Client::Appointment::Attendee.new(attendee[:a]))
        end

        comp_make_date
      end

      def search_make_date
        return if @json[:inst].nil? || @json[:inst].first.empty? || @json[:dur].nil?

        @appointment.start_at = Time.at(@json[:inst].first[:s] / 1000)
        @appointment.end_at = Time.at((@json[:inst].first[:s] + @json[:dur]) / 1000)
        @appointment.dur = @json[:dur] / 1000
      end

      def comp_make_date
        if comp_start_h[:u].nil?
          @appointment.start_at = Time.parse(comp_start_h[:d])
          @appointment.end_at = Time.parse(comp_end_h[:d])
        else
          @appointment.start_at = Time.at(comp_start_h[:u] / 1000)
          @appointment.end_at = Time.at(comp_end_h[:u] / 1000)
        end
      end

      def comp_start_h
        @comp_start_h ||= comp[:s].first
      end

      def comp_end_h
        @comp_end_h ||= comp[:e].first
      end

      def tz
        @tz ||= inv[:tz]&.first || { id: 'Europe/Berlin' }
      end

      def comp
        raise Zm::Client::ZmError, 'invalid appointment received' if inv[:comp].nil?

        @comp ||= inv[:comp].first
      end

      def comp_organizer_name
        return nil if comp[:or].nil?

        @comp_organizer_name ||= comp[:or][:a]
      end

      def search_organizer_name
        return nil if @json[:or].nil?

        @search_organizer_name ||= @json[:or][:a]
      end

      def attendees
        @attendees ||= comp[:at] || []
      end
    end
  end
end
