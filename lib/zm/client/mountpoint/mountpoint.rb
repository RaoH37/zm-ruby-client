# frozen_string_literal: true

module Zm
  module Client
    # class for account mountpoint
    class MountPoint < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[
        owner rev reminder ms deletable l rid uuid url f broken
        luuid ruuid activesyncdisabled absFolderPath view zid name id
        webOfflineSyncDays color rgb
      ].freeze

      attr_accessor(*INSTANCE_VARIABLE_KEYS)

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      alias parent_id l

      def initialize(parent, json = nil)
        @parent = parent
        @l = 1
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def create!
        rep = @parent.sacc.create_mountpoint(@parent.token, build_create_options)
        init_from_json(rep[:Body][:CreateMountpointResponse][:link].first)
      end

      def build_create_options
        {
          l: @l,
          name: @name,
          view: @view,
          zid: @zid,
          rid: @rid,
          url: @url,
          color: @color,
          rgb: @rgb,
          f: @f
        }.delete_if { |_, v| v.nil? }
      end

      def modify!
        update!(build_update_options)
      end

      def update!(options)
        @parent.sacc.folder_action(@parent.token, 'update', @id, options)
      end

      def build_update_options
        {
          f: @f,
          name: @name,
          l: @l,
          color: @color,
          rgb: @rgb
        }.delete_if { |_, v| v.nil? }
      end

      def rename!(new_name)
        @parent.sacc.folder_action(@parent.token, 'rename', @id, name: new_name)
        @name = new_name
      end

      def move!(folder_id)
        @parent.sacc.folder_action(@parent.token, 'move', @id, l: folder_id)
        @l = folder_id
      end

      def color!(new_color)
        key = new_color.to_i.zero? ? :rgb : :color
        options = {}
        options[key] = new_color
        @parent.sacc.folder_action(@parent.token, 'color', @id, options)
        instance_variable_set("@#{key}", new_color)
      end

      def delete!
        @parent.sacc.folder_action(@parent.token, :delete, @id)
      end

      def init_from_json(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          var_name = "@#{key}"
          instance_variable_set(var_name, json[key])
        end
      end
    end
  end
end
