# frozen_string_literal: true

module Zm
  module Client
    # class account SearchFolder
    class SearchFolder < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[id uuid deletable name absFolderPath l luuid color rev ms webOfflineSyncDays activesyncdisabled query sortBy types]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def init_from_json(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          var_name = "@#{key}"
          instance_variable_set(var_name, json[key])
        end
      end

      def create!
        rep = @parent.sacc.create_search_folder(@parent.token, name, query, types, l, color, sortBy)
        init_from_json(rep[:Body][:CreateSearchFolderResponse][:search].first)
      end

      def modify!
        @parent.sacc.modify_search_folder(@parent.token, id, query, types)
        @parent.sacc.folder_action(@parent.token, :update, id, { name: name, color: color })
      end

      def delete!
        @parent.sacc.folder_action(@parent.token, :delete, id)
      end

      def rename!(new_name)
        # todo
      end
    end
  end
end
