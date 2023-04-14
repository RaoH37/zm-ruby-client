# frozen_string_literal: true

module Zm
  module Client
    module BelongsToFolder
      def folder_id
        @l
      end

      def folder=(folder)
        return unless @l != folder.id

        @l = folder.id
        @folder = folder
      end

      def folder
        @folder || folder!
      end

      def folder!
        @folder = @parent.folders.all.find { |folder| folder.id == @l }
      end

      def move!(new_folder_id)
        new_folder_id = new_folder_id.id if new_folder_id.is_a?(Zm::Client::Folder)
        jsns = { action: { op: :move, id: @id, l: new_folder_id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
        @l = new_folder_id
        folder!
      end

      def trash!
        jsns = { action: { op: :trash, id: @id } }
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns)
      end
    end
  end
end
