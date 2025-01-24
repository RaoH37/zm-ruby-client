# frozen_string_literal: true

module Zm
  module Client
    # class account SearchFolder
    class SearchFolder < Base::Object
      # include Zm::Model::AttributeChangeObserver
      include RequestMethodsMailbox

      extend Philosophal::Properties

      cprop :id, Integer
      cprop :uuid, String
      cprop :name, String
      cprop :absFolderPath, Pathname
      cprop :l, Integer, default: FolderDefault::ROOT[:id]
      cprop :luuid, String
      cprop :color, Integer
      cprop :rgb, String
      cprop :rev, Integer
      cprop :ms, Integer
      cprop :webOfflineSyncDays, Integer
      cprop :activesyncdisabled, _Boolean
      cprop :deletable, _Boolean
      cprop :query, String
      cprop :sortBy, String
      cprop :types, String, default: 'messages'

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
