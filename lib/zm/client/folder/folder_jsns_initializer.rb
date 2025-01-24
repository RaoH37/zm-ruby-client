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
          item.cprop_inspect_map.keys.each do |k|
            next unless json[k]

            setter = :"#{k}="
            item.send(setter, json[k]) if item.respond_to?(setter)
          end

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
