# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Collection AccountSearchObjectsCollection
      class AccountSearchObjectsCollection < AccountObjectsCollection
        attr_accessor :more

        def initialize(parent)
          super
          @more = true
          reset_query_params
        end

        def find(id)
          rep = @parent.soap_connector.invoke(build_find(id))
          entry = rep[:GetMsgResponse][:m].first

          MessageJsnsInitializer.create(@parent, entry)
        end

        def build_find(id)
          SoapElement.mail(SoapMailConstants::GET_MSG_REQUEST)
                     .add_attributes({ m: { id: id, html: SoapUtils::ON } })
        end

        def start_at(start_at)
          @start_at = if start_at.is_a?(Time)
                        start_at.to_i * 1000
                      elsif start_at.is_a?(Date)
                        start_at.to_time.to_i * 1000
                      end
          self
        end

        def end_at(end_at)
          @end_at = if end_at.is_a?(Time)
                      end_at.to_i * 1000
                    elsif end_at.is_a?(Date)
                      end_at.to_time.to_i * 1000
                    end
          self
        end

        def folders(*folders)
          folders.flatten!
          folders.select! { |folder| folder.is_a?(Zm::Client::Folder) }
          return self if folders.empty?

          @folders = folders
          folder_ids(*@folders.map(&:id))
        end

        def folder_ids(*folder_ids)
          folder_ids.flatten!
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

        def make_query
          @parent.soap_connector.invoke(build_query)
        end

        def build_query
          jsns = {
            types: @type,
            offset: @offset,
            limit: @limit,
            sortBy: @sort_by,
            query: query,
            header: @headers
          }

          jsns.merge!(build_options)

          jsns.compact!

          SoapElement.mail(SoapMailConstants::SEARCH_REQUEST)
                     .add_attributes(jsns)
        end

        def delete_all(ids)
          attrs = {
            op: :delete,
            id: ids.join(',')
          }

          attrs.compact!

          soap_request = SoapElement.mail(SoapMailConstants::ITEM_ACTION_REQUEST)
          node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
          soap_request.add_node(node_action)
          @parent.soap_connector.invoke(soap_request)
        end

        private

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
          h = {
            resultMode: @resultMode,
            calExpandInstStart: @start_at,
            calExpandInstEnd: @end_at
          }
          h.compact!
          h
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
