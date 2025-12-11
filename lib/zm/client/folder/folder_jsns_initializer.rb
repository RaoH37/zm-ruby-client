# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account folder
    class FolderJsnsInitializer
      class << self
        def create(parent, json)
          item = Folder.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.type = json[:type]
          item.id = json[:id]
          item.uuid = json[:uuid]
          item.name = json[:name]
          item.absFolderPath = json[:absFolderPath]
          item.l = json[:l]
          item.url = json[:url]
          item.luuid = json[:luuid]
          item.f = json[:f]
          item.view = json[:view]
          item.rev = json[:rev]
          item.ms = json[:ms]
          item.webOfflineSyncDays = json[:webOfflineSyncDays]
          item.activesyncdisabled = json[:activesyncdisabled]
          item.n = json[:n]
          item.s = json[:s]
          item.i4ms = json[:i4ms]
          item.i4next = json[:i4next]
          item.zid = json[:zid]
          item.rid = json[:rid]
          item.ruuid = json[:ruuid]
          item.owner = json[:owner]
          item.reminder = json[:reminder]
          item.acl = json[:acl]
          item.itemCount = json[:itemCount]
          item.broken = json[:broken]
          item.deletable = json[:deletable]
          item.color = json[:color]
          item.rgb = json[:rgb]
          item.fb = json[:fb]

          if !json[:acl].nil? && json[:acl][:grant].is_a?(Array)
            json[:acl][:grant].each do |json|
              item.grants.create(json[:zid], json[:gt], json[:perm], json[:d])
            end
          end

          if json[:retentionPolicy].is_a?(Array)
            json[:retentionPolicy].first.map do |policy, v|
              next if v.first[:policy].nil?

              type = v.first[:policy].first[:type]
              lifetime = v.first[:policy].first[:lifetime]
              item.retention_policies.create(policy, lifetime, type)
            end
          end

          item.extend(DocumentFolder) if item.view == Zm::Client::FolderView::DOCUMENT

          item
        end
      end
    end
  end
end
