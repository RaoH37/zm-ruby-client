# frozen_string_literal: true

module Zm
  module Client
    # class account SearchFolder
    class SearchFolder < Base::Object
      # include Zm::Model::AttributeChangeObserver

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

      def build_create
        jsns_builder.to_jsns
      end

      def modify!
        @parent.sacc.invoke(build_modify)
        true
      end

      def build_modify
        jsns_builder.to_modify
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(new_name)
        return false if new_name == @name

        @parent.sacc.invoke(build_rename(new_name))
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      def color!
        @parent.sacc.invoke(build_color)
        true
      end

      def build_color
        jsns_builder.to_color
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(build_delete)
        @id = nil
      end

      def build_delete
        jsns_builder.to_delete
      end

      private

      def jsns_builder
        @jsns_builder ||= SearchFolderJsnsBuilder.new(self)
      end
    end
  end
end
