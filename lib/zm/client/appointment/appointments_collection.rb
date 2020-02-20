# frozen_string_literal: true

module Zm
  module Client
    # collection of appointments
    class AppointmentsCollection < Base::ObjectsCollection
      attr_accessor :more

      def initialize(parent)
        @parent = parent
        @more = true
        reset_query_params
      end

      def new
        appointment = Appointment.new(@parent)
        yield(appointment) if block_given?
        appointment
      end

      def start_at(start_at)
        @start_at = start_at
        self
      end

      def end_at(end_at)
        @end_at = end_at
        self
      end

      def folders(folders)
        @folders = folders
        @folder_ids = @folders.map(&:id)
        self
      end

      def folder_ids(folder_ids)
        @folder_ids = folder_ids
        self
      end

      def where(query)
        @query = query
        self
      end

      def ids
        search_builder.ids
      end

      private

      def search_response
        rep = @parent.sacc.search(@parent.token, 'appointment', @offset, @limit, 'dateAsc', query, build_options)
        @more = rep[:Body][:SearchResponse][:more]
        rep
      end

      def search_builder
        AppointmentsBuilder.new(@parent, search_response)
      end

      def build_response
        appointments = search_builder.make
        appointments.each { |appo| appo.folder = find_folder(appo) } unless @folders.empty?
        appointments
      end

      def build_options
        return {} if !@start_at.is_a?(Time) && !@end_at.is_a?(Time)

        {
          calExpandInstStart: (@start_at.to_f * 1000).to_i,
          calExpandInstEnd: (@end_at.to_f * 1000).to_i,
        }
      end

      def query
        return @query unless @query.nil?

        return nil if @folder_ids.empty?

        @folder_ids.map { |id| %Q{inid:"#{id}"} }.join(' OR ')
      end

      def find_folder(appointment)
        @folders.find { |folder| folder.id == appointment.l }
      end

      def reset_query_params
        super
        @start_at = nil
        @end_at = nil
        @query = nil
        @folder_ids = []
        @folders = []
      end
    end
  end
end
