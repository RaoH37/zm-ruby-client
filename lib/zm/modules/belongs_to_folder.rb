# frozen_string_literal: true

module Zm
  module Client
    module BelongsToFolder
      # def folder_id
      #   @l
      # end



      def folder=(folder)
        return if folder.nil?
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
        return if new_folder_id == @l

        @parent.soap_connector.invoke(jsns_builder.to_move(new_folder_id))
        @folder = nil
        @l = new_folder_id
      end

      def trash!
        @parent.soap_connector.invoke(jsns_builder.to_trash)
      end
    end
  end
end
