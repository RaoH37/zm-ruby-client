# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account mountpoint
    class MountpointJsnsInitializer
      class << self
        def create(parent, json)
          item = MountPoint.new(parent)

          item.instance_variable_set(:@id, json[:id])
          item.instance_variable_set(:@name, json[:name])

          update(item, json)
        end

        def update(item, json)
          item.all_instance_variable_keys.reject { |key| json[key].nil? }.each do |key|
            item.instance_variable_set(arrow_name(key), json[key])
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
