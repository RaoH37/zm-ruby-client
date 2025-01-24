# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::Object
      include BelongsToFolder
      include RequestMethodsMailbox
      # include Zm::Model::AttributeChangeObserver

      extend Philosophal::Properties

      cprop :owner, String
      cprop :reminder, String
      cprop :id, String
      cprop :uuid, String
      cprop :name, String
      cprop :absFolderPath, Pathname
      cprop :l, Integer, default: FolderDefault::ROOT[:id]
      cprop :luuid, String
      cprop :ruuid, String
      cprop :zid, String
      cprop :f, String
      cprop :color, Integer
      cprop :rgb, String
      cprop :rev, Integer
      cprop :ms, Integer
      cprop :url, String
      cprop :webOfflineSyncDays, Integer
      cprop :activesyncdisabled, _Boolean
      cprop :rid, String
      cprop :ruuid, String
      cprop :deletable, _Boolean
      cprop :view, String, default: FolderView::MESSAGE

      def create!
        rep = @parent.sacc.invoke(build_create)
        json = rep[:CreateMountpointResponse][:link].first

        MountpointJsnsInitializer.update(self, json)
        @id
      end

      def modify!
        raise NotImplementedError
      end

      def build_modify
        raise NotImplementedError
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

      def reload!
        raise NotImplementedError
      end

      private

      def jsns_builder
        @jsns_builder ||= MountpointJsnsBuilder.new(self)
      end
    end
  end
end
