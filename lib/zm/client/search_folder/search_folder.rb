# frozen_string_literal: true

module Zm
  module Client
    # class account SearchFolder
    class SearchFolder < Base::FolderObject
      include Zm::Model::AttributeChangeObserver

      INSTANCE_VARIABLE_KEYS = %i[id uuid deletable name absFolderPath l luuid color rgb rev ms webOfflineSyncDays activesyncdisabled query sortBy types]

      # attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_reader :id, :absFolderPath, :types

      define_changed_attributes :name, :color, :rgb, :l, :query, :sortBy

      def initialize(parent)
        super(parent)
        @types = 'messages'
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def create!
        rep = @parent.sacc.create_search_folder(@parent.token, jsns_builder.to_jsns)
        json = rep[:Body][:CreateSearchFolderResponse][:search].first
        SearchFolderJsnsInitializer.update(self, json)
      end

      def modify!
        @parent.sacc.modify_search_folder(@parent.token, jsns_builder.to_modify)
        super
      end

      private

      def jsns_builder
        @jsns_builder ||= SearchFolderJsnsBuilder.new(self)
      end
    end
  end
end
