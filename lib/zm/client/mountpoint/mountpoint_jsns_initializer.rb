# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account mountpoint
    class MountpointJsnsInitializer
      class << self
        def create(parent, json)
          MountPoint.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.name = json.delete(:name)
          item.owner = json.delete(:owner)
          item.rev = json.delete(:rev)
          item.reminder = json.delete(:reminder)
          item.ms = json.delete(:ms)
          item.deletable = json.delete(:deletable)
          item.rid = json.delete(:rid)
          item.uuid = json.delete(:uuid)
          item.url = json.delete(:url)
          item.f = json.delete(:f)
          item.broken = json.delete(:broken)
          item.luuid = json.delete(:luuid)
          item.ruuid = json.delete(:ruuid)
          item.activesyncdisabled = json.delete(:activesyncdisabled)
          item.absFolderPath = json.delete(:absFolderPath)
          item.view = json.delete(:view)
          item.zid = json.delete(:zid)
          item.webOfflineSyncDays = json.delete(:webOfflineSyncDays)
          item.l = json.delete(:l)
          item.color = json.delete(:color)
          item.rgb = json.delete(:rgb)

          item
        end
      end
    end
  end
end
