# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::Object
      include BelongsToFolder
      include Zm::Model::AttributeChangeObserver

      attr_accessor :owner, :rev, :reminder, :ms, :deletable, :rid, :uuid, :url, :f, :broken, :luuid, :ruuid,
                    :activesyncdisabled, :absFolderPath, :view, :zid, :id, :webOfflineSyncDays

      define_changed_attributes :name, :color, :rgb, :l

      def initialize(parent)
        @l = FolderDefault::ROOT[:id]
        super(parent)
      end

      def create!
        rep = @parent.sacc.invoke(jsns_builder.to_jsns)
        json = rep[:CreateMountpointResponse][:link].first

        MountpointJsnsInitializer.update(self, json)
        @id
      end

      def modify!
        raise NotImplementedError
      end

      def update!(*args)
        raise NotImplementedError
      end

      def color!
        @parent.sacc.invoke(jsns_builder.to_color) if color_changed? || rgb_changed?

        true
      end

      def rename!(new_name)
        return false if new_name == @name

        @parent.sacc.invoke(jsns_builder.to_rename(new_name))
        @name = new_name
      end

      def reload!
        raise NotImplementedError
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
      end

      private

      def jsns_builder
        @jsns_builder ||= MountpointJsnsBuilder.new(self)
      end
    end
  end
end
