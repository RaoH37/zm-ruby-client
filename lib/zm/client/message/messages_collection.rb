# frozen_string_literal: true

module Zm
  module Client
    # Collection Messages
    class MessagesCollection < Base::ObjectsCollection
      attr_accessor :more

      def initialize(parent)
        @parent = parent
        @more = true
        reset_query_params
      end


      def find(id)
        rep = @parent.sacc.get_msg(@parent.token, id, { part: 0 })
        entry = rep[:Body][:GetMsgResponse][:m].first
        puts entry
        msg = Message.new(@parent)
        msg.init_from_json(entry)
        msg
      end

      def new
        message = Message.new(@parent)
        yield(message) if block_given?
        message
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

      def all
        build_response
      end

      private

      def search_response
        rep = @parent.sacc.search(@parent.token, 'message', @offset, @limit, 'dateDesc', query, build_options)
        @more = rep[:Body][:SearchResponse][:more]
        rep
      end

      def search_builder
        MessagesBuilder.new(@parent, search_response)
      end

      def build_response
        messages = search_builder.make
        messages.each { |msg| msg.folder = find_folder(msg) } unless @folders.empty?
        messages
      end

      def build_options
        {}
      end

      def query
        return @query unless @query.nil?

        return nil if @folder_ids.empty?

        @folder_ids.map { |id| %Q{inid:"#{id}"} }.join(' OR ')
      end

      def find_folder(message)
        @folders.find { |folder| folder.id == message.l }
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
