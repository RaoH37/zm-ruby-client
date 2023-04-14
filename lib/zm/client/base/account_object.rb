# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AccountObject
      class AccountObject < Object
        # def soap_account_connector
        #   @parent.soap_account_connector
        # end
        #
        # alias sacc soap_account_connector

        def tag!(*new_tags)
          Utils.map_format(new_tags, String, :name)
          return false if new_tags.delete_if { |tag_name| tn.include?(tag_name) }.empty?

          new_tags.each do |tag_name|
            @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_tag(tag_name))
          end

          self.tn += new_tags
        end

        def create!
          @id
        end

        def modify!
          rename!
          true
        end

        def update!(hash)
          return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

          do_update!(hash)

          hash.each do |key, value|
            update_attribute(key, value)
          end

          true
        end

        def rename!(new_name)
          return false if new_name == @name

          @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_rename(new_name))
          @name = new_name
        end

        def delete!
          return false if @id.nil?

          @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_delete)
          @id = nil
        end

        # def move!(new_folder_id)
        #   new_folder_id = new_folder_id.id if new_folder_id.is_a?(Zm::Client::Folder)
        #   @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_move(new_folder_id))
        #   @l = new_folder_id
        #   folder!
        # end

        # def folder
        #   @folder || folder!
        # end

        # private
        #
        # def folder!
        #   @folder = @parent.folders.all.find { |folder| folder.id == @l }
        # end
      end
    end
  end
end
