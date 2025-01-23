# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::Object
      include BelongsToFolder
      # include Zm::Model::AttributeChangeObserver

      attr_accessor :owner, :rev, :reminder, :ms, :deletable, :rid, :uuid, :url, :f, :broken, :luuid, :ruuid,
                    :activesyncdisabled, :absFolderPath, :view, :zid, :id, :webOfflineSyncDays,
                    :name, :color, :rgb, :l

      # define_changed_attributes :name, :color, :rgb, :l

      def initialize(parent)
        @l = FolderDefault::ROOT[:id]
        super(parent)
      end

      def create!
        rep = @parent.sacc.invoke(build_create)
        json = rep[:CreateMountpointResponse][:link].first

        MountpointJsnsInitializer.update(self, json)
        @id
      end

      def build_create
        jsns_builder.to_jsns
      end

      def modify!
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

      def rename!(new_name)
        return false if new_name == @name

        @parent.sacc.invoke(build_rename(new_name))
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      def reload!
        raise NotImplementedError
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
        @jsns_builder ||= MountpointJsnsBuilder.new(self)
      end
    end
  end
end
