# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::FolderObject
      include Zm::Model::AttributeChangeObserver

      INSTANCE_VARIABLE_KEYS = %i[
        owner rev reminder ms deletable l rid uuid url f broken
        luuid ruuid activesyncdisabled absFolderPath view zid name id
        webOfflineSyncDays color rgb
      ].freeze

      attr_reader :owner, :rev, :reminder, :ms, :deletable, :rid, :uuid, :url, :f, :broken, :luuid, :ruuid, :activesyncdisabled, :absFolderPath, :view, :zid, :id, :webOfflineSyncDays

      define_changed_attributes :name, :color, :rgb, :l

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      alias parent_id l

      def create!
        rep = @parent.sacc.create_mountpoint(@parent.token, jsns_builder.to_jsns)
        json = rep[:Body][:CreateMountpointResponse][:link].first
        MountpointJsnsInitializer.update(self, json)
      end

      def update!(options)
        # todo
      end

      private

      def jsns_builder
        @jsns_builder ||= MountpointJsnsBuilder.new(self)
      end
    end
  end
end
