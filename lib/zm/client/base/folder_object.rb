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
          if color_changed? || rgb_changed?
            @parent.sacc.jsns_request(:FolderActionRequest, @parent.token,
                                      jsns_builder.to_color)
          end
          true
        end

        def delete!
          @parent.sacc.jsns_request(:FolderActionRequest, @parent.token, jsns_builder.to_delete)
          super
        end

        def modify!
          @parent.sacc.jsns_request(:FolderActionRequest, @parent.token, jsns_builder.to_update)
          true
        end

        def move!
          @parent.sacc.jsns_request(:FolderActionRequest, @parent.token, jsns_builder.to_move) if l_changed?
          true
        end
      end
    end
  end
end
