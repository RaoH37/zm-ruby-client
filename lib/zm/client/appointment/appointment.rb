# frozen_string_literal: true

module Zm
  module Client
    # class for account appointment
    class Appointment < Base::Object
      include BelongsToFolder
      include BelongsToTag
      include RequestMethodsMailbox
      include MailboxItemConcern

      attr_accessor :uid, :name, :desc, :start_at, :dur, :end_at, :tn, :allDay, :organizer, :timezone,
                    :calItemId, :apptId, :invId, :rev, :fb, :transp
      attr_reader :recipients, :attendees, :body

      alias description desc

      def initialize(parent)
        @parent = parent
        @recipients = Recipients.new
        @body = BodyMail.new
        @attendees = Attendees.new
        @allDay = false
        @timezone = 'Europe/Berlin'

        yield(self) if block_given?
      end

      def download(dest_file_path, fmt: 'ics')
        uploader = @parent.build_uploader
        uploader.download_file(dest_file_path, id, FolderView::APPOINTMENT, fmt:)
      end

      def create!
        rep = @parent.soap_connector.invoke(build_create)

        aji = AppointmentJsnsInitializer.new(@parent, rep[:CreateAppointmentResponse])
        aji.appointment = self
        aji.update
        id
      end

      def build_create
        SoapElement.mail(SoapMailConstants::CREATE_APPOINTMENT_REQUEST)
                   .add_attributes(jsns_builder.to_jsns)
      end

      def build_modify
        SoapElement.mail(SoapMailConstants::MODIFY_APPOINTMENT_REQUEST)
                   .add_attributes(jsns_builder.to_update)
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
      end

      def reload!
        jsns = { m: { id: id, html: SoapUtils::ON } }

        soap_request = SoapElement.mail(SoapMailConstants::GET_MSG_REQUEST)
                                  .add_attributes(jsns)
        rep = @parent.soap_connector.invoke(soap_request)
        entry = rep[:GetMsgResponse][:m].first

        aji = AppointmentJsnsInitializer.new(@parent, entry)
        aji.appointment = self
        aji.create
      end

      def free!
        self.fb = 'F'
        self.transp = 'O'
      end

      def busy!
        self.fb = 'B'
        self.transp = 'T'
      end

      def must_confirm!
        self.fb = 'T'
        self.transp = 'T'
      end

      def out_of_office!
        self.fb = 'O'
        self.transp = 'O'
      end

      class Organizer
        attr_accessor :email, :display_name

        def initialize(email, display_name = nil)
          @email = email
          @display_name = display_name
        end
      end

      # Collection attendees
      class Attendees
        def initialize
          @attendees = []
        end

        def map(&)
          @attendees.map(&)
        end

        def add(attendee)
          return unless attendee.is_a?(Attendee)

          @attendees.push(attendee)
        end

        def del(attendee)
          case attendee
          when Attendee
            @attendees.delete(attendee)
          when String
            @attendees.delete_if { |at| at.email == attendee }
          end
        end

        def clear
          @attendees.clear
        end
      end

      # Class one recipient for email
      class Attendee
        attr_accessor :email, :display_name, :role, :ptst, :rsvp

        def initialize(email, display_name = nil, role = 'REQ', ptst = 'NE', rsvp = 1)
          @email = email
          @display_name = display_name
          @role = role
          @ptst = ptst
          @rsvp = rsvp
        end
      end

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = AppointmentJsnsBuilder.new(self)
      end
    end
  end
end
