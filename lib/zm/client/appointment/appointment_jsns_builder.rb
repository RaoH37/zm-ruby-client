# frozen_string_literal: true

module Zm
  module Client
    # class for account appointment
    class AppointmentJsnsBuilder

      def initialize(appointment)
        @appointment = appointment
      end

      def to_delete
        {
          comp: 0,
          id: @appointment.id
        }
      end

      def to_jsns
        {
          m: {
            l: @appointment.l,
            su: @appointment.name,
            e: recipients_to_jsns,
            mp: body_to_jsns,
            inv: {
              comp: comp_to_jsns
            }
          }
        }
      end

      alias to_create to_jsns

      def to_update
        jsns = to_jsns
        jsns[:comp] = 0
        jsns[:id] = @appointment.id
        jsns[:m][:inv][:uid] = @appointment.uid
        jsns
      end

      def recipients_to_jsns
        @appointment.recipients.map do |recipient|
          {
            t: recipient.field,
            a: recipient.email,
            p: recipient.display_name
          }.reject { |_, v| v.nil? }
        end
      end

      def body_to_jsns
        [
          {
            ct: 'multipart/alternative',
            mp: [body_text_jsns, body_html_jsns]
          }
        ]
      end

      def body_text_jsns
        { ct: 'text/plain', content: { _content: @appointment.body.text } }
      end

      def body_html_jsns
        { ct: 'text/html', content: { _content: @appointment.body.html } }
      end

      def comp_to_jsns
        [
          {
            allDay: @appointment.allDay,
            at: attendees_to_jsns,
            e: end_at_jsns,
            s: start_at_jsns,
            or: organizer_to_jsns,
            name: @appointment.name
          }.reject { |_, v| v.nil? }
        ]
      end

      def attendees_to_jsns
        @appointment.attendees.map do |attendee|
          {
            a: attendee.email,
            d: attendee.display_name,
            role: attendee.role,
            ptst: attendee.ptst,
            rsvp: attendee.rsvp
          }.reject { |_, v| v.nil? }
        end
      end

      def end_at_jsns
        {
          d: @appointment.end_at.strftime(time_format),
          tz: @appointment.timezone
        }
      end

      def start_at_jsns
        {
          d: @appointment.start_at.strftime(time_format),
          tz: @appointment.timezone
        }
      end

      def organizer_to_jsns
        return nil if @appointment.organizer.nil?

        {
          a: @appointment.organizer.email,
          d: @appointment.organizer.display_name
        }.reject { |_, v| v.nil? }
      end

      def time_format
        @time_format ||= @appointment.allDay ? '%Y%m%d' : '%Y%m%dT%H%M00'
      end
    end
  end
end
