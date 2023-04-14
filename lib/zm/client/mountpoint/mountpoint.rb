# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::FolderObject
      include BelongsToFolder
      include Zm::Model::AttributeChangeObserver

      attr_accessor :owner, :rev, :reminder, :ms, :deletable, :rid, :uuid, :url, :f, :broken, :luuid, :ruuid,
                    :activesyncdisabled, :absFolderPath, :view, :zid, :id, :webOfflineSyncDays

      define_changed_attributes :name, :color, :rgb, :l

      # alias folder_id l

      def create!
        rep = @parent.sacc.jsns_request(:CreateMountpointRequest, @parent.token, jsns_builder.to_jsns)
        json = rep[:Body][:CreateMountpointResponse][:link].first
        MountpointJsnsInitializer.update(self, json)
      end

      private

      def jsns_builder
        @jsns_builder ||= MountpointJsnsBuilder.new(self)
      end
    end
  end
end
