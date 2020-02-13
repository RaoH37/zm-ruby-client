# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[id name color rgb u n d rev md ms]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def init_from_json(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          instance_variable_set(arrow_name(key), json[key])
        end
      end

      def create!
        rep = @parent.sacc.create_tag(@parent.token, @name, @color, @rgb)
        init_from_json(rep[:Body][:CreateTagResponse][:tag].first)
      end

      def modify!
        @parent.sacc.tag_action(@parent.token, :update, @id, { color: @color, rgb: @rgb })
      end

      def delete!
        @parent.sacc.tag_action(@parent.token, :delete, @id)
      end

      def rename!(new_name)
        @parent.sacc.tag_action(
          @parent.token,
          :rename,
          @id,
          name: new_name
        )
      end
    end
  end
end
