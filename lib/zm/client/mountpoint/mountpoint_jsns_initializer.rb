# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account mountpoint
    class MountpointJsnsInitializer
      class << self
        def create(parent, json)
          item = MountPoint.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]
          item.owner = json[:owner]
          item.rev = json[:rev]
          item.reminder = json[:reminder]
          item.ms = json[:ms]
          item.deletable = json[:deletable]
          item.rid = json[:rid].to_i
          item.uuid = json[:uuid]
          item.url = json[:url]
          item.f = json[:f]
          item.broken = json[:broken]
          item.luuid = json[:luuid]
          item.ruuid = json[:ruuid]
          item.activesyncdisabled = json[:activesyncdisabled]
          item.absFolderPath = json[:absFolderPath]
          item.view = json[:view]
          item.zid = json[:zid]
          item.webOfflineSyncDays = json[:webOfflineSyncDays]
          item.l = json[:l]
          item.color = json[:color].to_i
          item.rgb = json[:rgb].to_i

          item
        end
      end
    end
  end
end
