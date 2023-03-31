# frozen_string_literal: true

module Zm
  module Client
    # class for account appointment
    class Appointment < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[id uid name l desc start_at dur end_at tn allDay organizer timezone calItemId apptId invId rev fb transp]

      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_writer :folder
      attr_reader :json
      attr_reader :recipients, :attendees, :body

      alias description desc
      alias parent_id l

      # def initialize(parent, json = nil)
      def initialize(parent)
        @parent = parent
        @recipients = Recipients.new
        @body = BodyMail.new
        @attendees = Attendees.new
        @allDay = false
        @timezone = 'Europe/Berlin'
        yield(self) if block_given?
      end

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def folder
        @folder ||= @parent.folders.all.find { |folder| folder.id == l }
      end

      def download(dest_file_path, fmt = 'ics')
        # @parent.uploader.download_file(folder.absFolderPath, 'ics', ['appointment'], [id], dest_file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_file(folder.absFolderPath, fmt, ['appointment'], [id], dest_file_path)
      end

      def create!
        jsns_builder = AppointmentJsnsBuilder.new(self)
        rep = @parent.sacc.create_appointment(@parent.token, jsns_builder.to_jsns)
        rep_h = rep[:Body][:CreateAppointmentResponse]

        aji = AppointmentJsnsInitializer.new(@parent, rep_h)
        aji.appointment = self
        aji.update
      end

      def modify!
        jsns_builder = AppointmentJsnsBuilder.new(self)
        @parent.sacc.modify_appointment(@parent.token, jsns_builder.to_update)
      end

      def reload!
        rep = @parent.sacc.get_msg(@parent.token, @id)
        entry = rep[:Body][:GetMsgResponse][:m].first
        aji = AppointmentJsnsInitializer.new(@parent, entry)
        aji.appointment = self
        aji.create
      end

      def delete!
        jsns_builder = AppointmentJsnsBuilder.new(self)
        @parent.sacc.cancel_appointment(@parent.token, jsns_builder.to_delete)
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

        def map(&block)
          @attendees.map(&block)
        end

        def add(attendee)
          return unless attendee.is_a?(Attendee)

          @attendees.push(attendee)
        end

        def del(attendee)
          if attendee.is_a?(Attendee)
            @attendees.delete(attendee)
          elsif attendee.is_a?(String)
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
    end
  end
end
