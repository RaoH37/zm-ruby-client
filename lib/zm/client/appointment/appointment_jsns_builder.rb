# frozen_string_literal: true

module Zm
  module Client
    # class for account appointment
    class AppointmentJsnsBuilder < BaseAccountJsnsBuilder
      def to_jsns
        {
          m: {
            l: @item.l,
            su: @item.name,
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
        jsns[:id] = @item.id
        jsns[:m][:inv][:uid] = @item.uid
        jsns
      end

      def recipients_to_jsns
        @item.recipients.map do |recipient|
          {
            t: recipient.field,
            a: recipient.email,
            p: recipient.display_name
          }.compact
        end
      end

      def body_to_jsns
        [
          {
            ct: ContentPart::ALTERNATIVE,
            mp: [body_text_jsns, body_html_jsns]
          }
        ]
      end

      def body_text_jsns
        { ct: ContentType::TEXT, content: { _content: @item.body.text } }
      end

      def body_html_jsns
        { ct: ContentType::HTML, content: { _content: @item.body.html } }
      end

      def comp_to_jsns
        [
          {
            allDay: @item.allDay,
            at: attendees_to_jsns,
            e: end_at_jsns,
            s: start_at_jsns,
            or: organizer_to_jsns,
            name: @item.name,
            fb: @item.fb,
            transp: @item.transp
          }.compact
        ]
      end

      def attendees_to_jsns
        @item.attendees.map do |attendee|
          {
            a: attendee.email,
            d: attendee.display_name,
            role: attendee.role,
            ptst: attendee.ptst,
            rsvp: attendee.rsvp
          }.compact
        end
      end

      def end_at_jsns
        {
          d: @item.end_at.strftime(time_format),
          tz: @item.timezone
        }
      end

      def start_at_jsns
        {
          d: @item.start_at.strftime(time_format),
          tz: @item.timezone
        }
      end

      def organizer_to_jsns
        return nil if @item.organizer.nil?

        {
          a: @item.organizer.email,
          d: @item.organizer.display_name
        }.compact
      end

      def time_format
        return @time_format if defined? @time_format

        @time_format = @item.allDay ? '%Y%m%d' : '%Y%m%dT%H%M00'
      end
    end
  end
end
