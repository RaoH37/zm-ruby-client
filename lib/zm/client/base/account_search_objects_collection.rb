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
          jsns = { m: { id: id, html: 1 } }

          soap_request = SoapElement.mail(SoapMailConstants::GET_MSG_REQUEST).add_attributes(jsns)
          rep = @parent.sacc.invoke(soap_request)
          entry = rep[:GetMsgResponse][:m].first

          MessageJsnsInitializer.create(@parent, entry)
        end

        def start_at(start_at)
          @start_at = start_at
          self
        end

        def end_at(end_at)
          @end_at = end_at
          self
        end

        def folders(*folders)
          folders.select! { |folder| folder.is_a?(Zm::Client::Folder) }
          return self if folders.empty?

          @folders = folders
          folder_ids(*@folders.map(&:id))
        end

        def folder_ids(*folder_ids)
          folder_ids.uniq!
          return self if @folder_ids == folder_ids

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
          jsns = {
            types: @type,
            offset: @offset,
            limit: @limit,
            sortBy: @sort_by,
            query: query,
            header: @headers
          }

          jsns.merge!(build_options)

          jsns.reject! { |_, v| v.nil? }

          soap_request = SoapElement.mail(SoapMailConstants::SEARCH_REQUEST).add_attributes(jsns)
          @parent.sacc.invoke(soap_request)
        end

        def search_builder
          @builder_class.new(@parent, search_response)
        end

        def search_response
          rep = make_query
          @more = rep[:SearchResponse][:more]
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

          @folder_ids.map { |id| %(inid:"#{id}") }.join(' OR ')
        end

        def build_options
          start_at_ts = @start_at.is_a?(Time) ? (@start_at.to_f * 1000).to_i : nil
          end_at_ts = @end_at.is_a?(Time) ? (@end_at.to_f * 1000).to_i : nil

          {
            resultMode: @resultMode,
            calExpandInstStart: start_at_ts,
            calExpandInstEnd: end_at_ts
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
          @headers = [{ n: 'messageIdHeader' }]
        end
      end
    end
  end
end
