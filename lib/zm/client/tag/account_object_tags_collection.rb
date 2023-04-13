# frozen_string_literal: true

module Zm
  module Client
    class AccountObject
      class TagsCollection
        def initialize(parent)
          @parent = parent
        end

        def all
          @all || all!
        end

        def all!
          @all = @parent.tn
        end

        def add!(*new_tags)
          Utils.map_format(new_tags, String, :name)
          return false if new_tags.delete_if { |tag_name| all.include?(tag_name) }.empty?

          new_tags.each do |tag_name|
            jsns = { action: { op: :tag, id: @parent.id, tn: tag_name } }
            @parent.parent.sacc.jsns_request(:ItemActionRequest, @parent.parent.token, jsns)
          end

          @parent.tn += new_tags
          all!
        end

        def remove!(*tag_names)
          Utils.map_format(tag_names, String, :name)
          return false if tag_names.delete_if { |tag_name| !all.include?(tag_name) }.empty?

          tag_names.each do |tag_name|
            jsns = { action: { op: '!tag', id: @parent.id, tn: tag_name } }
            @parent.parent.sacc.jsns_request(:ItemActionRequest, @parent.parent.token, jsns)
          end

          @parent.tn -= tag_names
          all!
        end
      end
    end
  end
end
