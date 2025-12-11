# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account folder
    class FolderJsnsInitializer
      class << self
        def create(parent, json)
          Folder.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.type = json.delete(:type)
          item.id = json.delete(:id)
          item.uuid = json.delete(:uuid)
          item.name = json.delete(:name)
          item.absFolderPath = json.delete(:absFolderPath)
          item.l = json.delete(:l)
          item.url = json.delete(:url)
          item.luuid = json.delete(:luuid)
          item.f = json.delete(:f)
          item.view = json.delete(:view)
          item.rev = json.delete(:rev)
          item.ms = json.delete(:ms)
          item.webOfflineSyncDays = json.delete(:webOfflineSyncDays)
          item.activesyncdisabled = json.delete(:activesyncdisabled)
          item.n = json.delete(:n)
          item.s = json.delete(:s)
          item.i4ms = json.delete(:i4ms)
          item.i4next = json.delete(:i4next)
          item.zid = json.delete(:zid)
          item.rid = json.delete(:rid)
          item.ruuid = json.delete(:ruuid)
          item.owner = json.delete(:owner)
          item.reminder = json.delete(:reminder)
          item.acl = json.delete(:acl)
          item.itemCount = json.delete(:itemCount)
          item.broken = json.delete(:broken)
          item.deletable = json.delete(:deletable)
          item.color = json.delete(:color)
          item.rgb = json.delete(:rgb)
          item.fb = json.delete(:fb)

          grants = json.dig(:acl, :grant)
          if grants.is_a?(Array)
            grants.each do |grant|
              item.grants.create(
                grant.delete(:zid),
                grant.delete(:gt),
                grant.delete(:perm),
                grant.delete(:d)
              )
            end
          end

          if (policies = json.fetch(:retentionPolicy, []).first).is_a?(Array)
            policies.each do |policy, v|
              params = v.first[:policy]&.first
              next if params.nil?

              type = params.delete(:type)
              lifetime = params.delete(:lifetime)
              item.retention_policies.create(policy, lifetime, type)
            end
          end

          # if json[:retentionPolicy].is_a?(Array)
          #   json[:retentionPolicy].first.each do |policy, v|
          #     next if v.first[:policy].nil?
          #
          #     type = v.first[:policy].first[:type]
          #     lifetime = v.first[:policy].first[:lifetime]
          #     item.retention_policies.create(policy, lifetime, type)
          #   end
          # end

          item.extend(DocumentFolder) if item.view == Zm::Client::FolderView::DOCUMENT

          item
        end
      end
    end
  end
end
