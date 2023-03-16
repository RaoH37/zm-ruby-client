# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AccountObject
      class AccountObject < Object
        def soap_account_connector
          @parent.soap_account_connector
        end

        alias sacc soap_account_connector

        # def concat
        #   all_instance_variable_keys.map { |key| instance_variable_get(arrow_name(key)) }
        # end

        # def init_from_json(json)
        #   all_instance_variable_keys.each do |key|
        #     next if json[key].nil?
        #
        #     instance_variable_set(arrow_name(key), json[key])
        #   end
        # end
        #
        # def to_h
        #   hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        #   hashmap.delete_if { |_, v| v.nil? }
        #   hashmap
        # end

        def tag!(*new_tags)
          Utils.map_format(new_tags, String, :name)
          return false if new_tags.delete_if { |tag_name| tn.include?(tag_name) }.empty?

          new_tags.each do |tag_name|
            @parent.sacc.item_action(@parent.token, jsns_builder.to_tag(tag_name))
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

        def rename!(new_name)
          return false if new_name == @name
          @parent.sacc.item_action(@parent.token, jsns_builder.to_rename(new_name))
          @name = new_name
        end

        def delete!
          return false if @id.nil?
          @parent.sacc.item_action(@parent.token, jsns_builder.to_delete)
          remove_instance_variable(:@id)
        end

        def move!(new_folder_id)
          new_folder_id = new_folder_id.id if new_folder_id.is_a?(Zm::Client::Folder)
          @parent.sacc.item_action(@parent.token, jsns_builder.to_move(new_folder_id))
          @l = new_folder_id
          folder!
        end

        def folder
          @folder || folder!
        end

        private

        def folder!
          @folder = @parent.folders.all.find { |folder| folder.id == @l }
        end
      end
    end
  end
end
