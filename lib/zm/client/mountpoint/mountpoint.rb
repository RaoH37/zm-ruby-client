# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::Object
      include BelongsToFolder
      include RequestMethodsMailbox
      include MailboxItemConcern

      attr_accessor :owner, :rev, :reminder, :ms, :deletable, :rid, :uuid, :url, :f, :broken, :luuid, :ruuid,
                    :activesyncdisabled, :absFolderPath, :view, :zid, :webOfflineSyncDays, :name, :color, :rgb

      def initialize(parent)
        @l = FolderDefault::ROOT.id
        super(parent)
      end

      def create!
        rep = @parent.soap_connector.invoke(build_create)
        json = rep[:CreateMountpointResponse][:link].first

        MountpointJsnsInitializer.update(self, json)
        id
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
        @parent.soap_connector.invoke(build_color)
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
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = MountpointJsnsBuilder.new(self)
      end
    end
  end
end
