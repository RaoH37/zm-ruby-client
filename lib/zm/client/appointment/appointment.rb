# frozen_string_literal: true

module Zm
  module Client
    # class for account appointment
    class Appointment < Base::AccountObject
      attr_accessor :id, :uid, :name, :l, :desc, :start_at, :dur, :end_at

      alias description desc
      alias parent_id l

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def concat
        [ @id, @uid, @name, @l, @desc, @start_at, @dur ]
      end

      def create!
        # rep = @parent.sacc.create_appointment(@parent.token, @l, @name, @view)
        # init_from_json(rep[:Body][:CreateAppointmentResponse][:appointment].first)
      end

      def reload!
        # rep = @parent.sacc.get_appointment(@parent.token, @id)
        # init_from_json(rep[:Body][:GetAppointmentResponse][:appointment].first)
      end

      def delete!
        # @parent.sacc.appointment_action(@parent.token, :delete, @id)
      end

      def init_from_json(json)
        @id       = json[:id].to_i
        @uid      = json[:uid]
        @name     = json[:name]
        @l        = json[:l]
        @desc     = json[:fr]
        @start_at = Time.at(json[:inst].first[:s] / 1000)
        @dur      = json[:dur] / 1000
        @end_at   = Time.at((json[:inst].first[:s] + json[:dur]) / 1000)
      end
    end
  end
end
