# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class FolderObject
      class FolderObject < AccountObject

        def initialize(parent)
          @l = FolderDefault::ROOT[:id]
          super(parent)
        end

        def color!
          @parent.sacc.folder_action(@parent.token, jsns_builder.to_color) if color_changed? || rgb_changed?
          true
        end

        def delete!
          @parent.sacc.folder_action(@parent.token, jsns_builder.to_delete)
          super
        end

        def modify!
          @parent.sacc.folder_action(@parent.token, jsns_builder.to_update)
          true
        end

        def move!
          @parent.sacc.folder_action(@parent.token, jsns_builder.to_move) if l_changed?
          true
        end

        def rename!
          @parent.sacc.folder_action(@parent.token, jsns_builder.to_rename) if name_changed?
          super
        end
      end
    end
  end
end
