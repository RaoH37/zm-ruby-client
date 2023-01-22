# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account folder
    class FolderJsnsInitializer
      class << self
        def create(parent, json)
          item = Folder.new(parent)

          item.instance_variable_set(:@id, json[:id])
          item.instance_variable_set(:@name, json[:name])

          update(item, json)
        end

        def update(item, json)
          item.all_instance_variable_keys.reject { |key| json[key].nil? }.each do |key|
            item.instance_variable_set(arrow_name(key), json[key])
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

          item
        end

        def arrow_name(name)
          return name if name.to_s.start_with?('@')

          "@#{name}"
        end
      end
    end
  end
end
