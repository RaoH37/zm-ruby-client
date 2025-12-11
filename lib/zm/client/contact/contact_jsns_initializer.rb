# frozen_string_literal: true

module Zm
  module Client
    # class for account contact
    class ContactJsnsInitializer
      class << self
        def create(parent, json)
          item = Contact.new(parent)
          update(item, json)
        end

        def update(item, json)
          # part_id = json[:id].split(':')
          #
          # if part_id.length == 1
          #   item.id = json[:id].to_i
          # elsif part_id.length == 2
          #   item.shared_account_id = part_id.first
          #   item.id = part_id.last.to_i
          # else
            item.id = json[:id]
          # end

          # part_l = json[:l].split(':')
          #
          # if part_l.length == 1
          #   item.l = json[:l].to_i
          # elsif part_l.length == 2
          #   item.shared_folder_account_id = part_l.first
          #   item.l = part_l.last.to_i
          # else
            item.l = json[:l]
          # end

          # item.id   = json[:id]
          item.name = json[:fileAsStr]
          # item.l    = json[:l].to_i
          item.tn   = json[:tn]

          if json[:_attrs].is_a?(Hash)
            make_custom_keys(json[:_attrs], item)
            init_by_attrs(json[:_attrs], item)
          end

          if item.group?
            item.extend(GroupContact)
            init_members_from_json(json[:m], item)
          end

          item
        end

        def make_custom_keys(attrs, item)
          custom_keys = attrs.keys - item.all_instance_variable_keys
          return if custom_keys.empty?

          item.class.attr_accessor(*custom_keys)
        rescue StandardError => _e
          nil
        end

        def init_by_attrs(attrs, item)
          attrs.each do |k, v|
            m = Utils.equals_name(k)
            item.send(m, v) if item.respond_to?(m)
          end
        end

        def init_members_from_json(m, item)
          return if m.nil?

          item.members.all = m.map { |m| Zm::Client::ConcatMember.new(m[:type], m[:value]) }
        end
      end
    end
  end
end
