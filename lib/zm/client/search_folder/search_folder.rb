# frozen_string_literal: true

module Zm
  module Client
    # class account SearchFolder
    class SearchFolder < Base::Object
      # include Zm::Model::AttributeChangeObserver
      include RequestMethodsMailbox

      attr_accessor :id, :uuid, :deletable, :name, :absFolderPath, :l, :luuid, :color, :rgb, :rev, :ms,
                    :webOfflineSyncDays, :activesyncdisabled, :query, :sortBy, :types,
                    :name, :color, :rgb, :l, :query, :sortBy

      # define_changed_attributes :name, :color, :rgb, :l, :query, :sortBy

      def initialize(parent)
        @l = FolderDefault::ROOT[:id]
        @types = 'messages'
        super(parent)
      end

      def create!
        rep = @parent.sacc.invoke(build_create)
        json = rep[:CreateSearchFolderResponse][:search].first
        SearchFolderJsnsInitializer.update(self, json)
        @id
      end

      def update!(*args)
        raise NotImplementedError
      end

      def color!
        @parent.sacc.invoke(build_color)
        true
      end

      def build_color
        jsns_builder.to_color
      end

      private

      def jsns_builder
        @jsns_builder ||= SearchFolderJsnsBuilder.new(self)
      end
    end
  end
end
