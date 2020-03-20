# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class FolderGrant < Base::AccountObject
      attr_accessor :zid, :gt, :perm, :d

      class << self
        def create_by_json(parent, json)
          fg = self.new(parent)
          fg.init_from_json(json)
          fg
        end
      end

      def init_from_json(json)
        @zid = json[:zid]
        @gt = json[:gt]
        @perm = json[:perm]
        @d = json[:d]
      end
    end
  end
end
