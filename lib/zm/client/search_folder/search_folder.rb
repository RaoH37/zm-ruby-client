# frozen_string_literal: true

module Zm
  module Client
    # class account SearchFolder
    class SearchFolder < Base::Object
      include Zm::Model::AttributeChangeObserver

      attr_accessor :id, :uuid, :deletable, :name, :absFolderPath, :l, :luuid, :color, :rgb, :rev, :ms,
                    :webOfflineSyncDays, :activesyncdisabled, :query, :sortBy, :types

      define_changed_attributes :name, :color, :rgb, :l, :query, :sortBy

      def initialize(parent)
        @l = FolderDefault::ROOT[:id]
        @types = 'messages'
        super(parent)
      end

      def create!
        rep = @parent.sacc.invoke(jsns_builder.to_jsns)
        json = rep[:CreateSearchFolderResponse][:search].first
        SearchFolderJsnsInitializer.update(self, json)
        @id
      end

      def modify!
        @parent.sacc.invoke(jsns_builder.to_modify)
        true
      end

      def update!(*args)
        raise NotImplementedError
      end

      def rename!(new_name)
        return false if new_name == @name

        @parent.sacc.invoke(jsns_builder.to_rename(new_name))
        @name = new_name
      end

      def color!
        if color_changed? || rgb_changed?
          @parent.sacc.invoke(jsns_builder.to_color)
        end

        true
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
      end

      private

      def jsns_builder
        @jsns_builder ||= SearchFolderJsnsBuilder.new(self)
      end
    end
  end
end
