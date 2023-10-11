# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Collection AccountSearchObjectsCollection
      class AccountSearchObjectsCollection < AccountObjectsCollection
        attr_accessor :more

        def initialize(parent)
          super(parent)
          @more = true
          reset_query_params
        end

        def find(id)
          rep = @parent.sacc.get_msg(@parent.token, id, { html: 1 })
          entry = rep[:Body][:GetMsgResponse][:m].first

          msg = @child_class.new(@parent)
          msg.init_from_json(entry)
          msg
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

        def order(sort_by)
          return self if @sort_by == sort_by

          @all = nil
          @sort_by = sort_by
          self
        end

        def ids
          @resultMode = 'IDS'
          search_builder.ids
        end

        def reset
          reset_query_params
        end

        private

        def make_query
          @parent.sacc.search(@parent.token, @type, @offset, @limit, @sort_by, query, build_options)
        end

        def search_builder
          @builder_class.new(@parent, search_response)
        end

        def search_response
          rep = make_query
          @more = rep[:Body][:SearchResponse][:more]
          rep
        end

        def build_response
          items = search_builder.make
          items.each { |item| item.folder = find_folder(item) } unless @folders.empty?
          items
        end

        def find_folder(item)
          @folders.find { |folder| folder.id == item.l }
        end

        def query
          return @query unless @query.nil?

          return nil if @folder_ids.empty?

          @folder_ids.map { |id| %Q{inid:"#{id}"} }.join(' OR ')
        end

        def build_options
          start_at_ts = @start_at.is_a?(Time) ? (@start_at.to_f * 1000).to_i : nil
          end_at_ts = @end_at.is_a?(Time) ? (@end_at.to_f * 1000).to_i : nil

          {
            resultMode: @resultMode,
            calExpandInstStart: start_at_ts,
            calExpandInstEnd: end_at_ts,
          }.delete_if { |_, v| v.nil? }
        end

        def reset_query_params
          super
          @resultMode = 'NORMAL'
          @start_at = nil
          @end_at = nil
          @query = nil
          @folder_ids = []
          @folders = []
        end
      end
    end
  end
end
