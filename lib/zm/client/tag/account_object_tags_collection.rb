# frozen_string_literal: true

module Zm
  module Client
    class AccountObject
      class TagsCollection
        def initialize(parent)
          @parent = parent
        end

        def all
          return @all if defined? @all

          @all = @parent.tn.to_s.split(',')
        end

        def add!(*new_tags)
          new_tags.flatten!
          Utils.map_format(new_tags, String, :name)
          return false if new_tags.delete_if { |tag_name| all.include?(tag_name) }.empty?

          new_tags.each do |tag_name|
            attrs = {
              op: :tag,
              id: @parent.id,
              tn: tag_name
            }

            do_action(attrs)
          end

          @all += new_tags
          update_parent
        end

        def remove!(*tag_names)
          tag_names.flatten!
          Utils.map_format(tag_names, String, :name)
          return false if tag_names.delete_if { |tag_name| !all.include?(tag_name) }.empty?

          tag_names.each do |tag_name|
            attrs = {
              op: '!tag',
              id: @parent.id,
              tn: tag_name
            }

            do_action(attrs)
          end

          @all -= tag_names
          update_parent
        end

        def update_parent
          @parent.tn = @all.join(',')
        end

        def do_action(attrs)
          soap_request = SoapElement.mail(SoapMailConstants::ITEM_ACTION_REQUEST)
          node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
          soap_request.add_node(node_action)

          @parent.parent.soap_connector.invoke(soap_request)
        end
      end
    end
  end
end
