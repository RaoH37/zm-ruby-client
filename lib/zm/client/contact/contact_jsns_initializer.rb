# frozen_string_literal: true

module Zm
  module Client
    # class for account contact
    class ContactJsnsInitializer
      SETTERS = Hash.new { |h, name| h[name] = :"#{name}=" }
      CUSTOM_KEY_REGEX = /\A[a-zA-Z_][a-zA-Z0-9_]*\z/

      class << self
        def create(parent, json)
          item = Contact.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.l = json.delete(:l)
          item.name = json.delete(:fileAsStr)
          item.tn   = json.delete(:tn)

          init_by_attrs(json[:_attrs], item) if json[:_attrs].is_a?(Hash)

          if item.group?
            item.extend(Zm::Client::ModGroupContact)
            init_members_from_json(json[:m], item)
          end

          item
        end

        def init_by_attrs(attrs, item)
          attrs.each do |key, value|
            setter = SETTERS[key]

            if item.respond_to?(setter)
              item.public_send(setter, value)
            elsif custom_key?(key)
              item.add_custom_property(key, value)
            end
          end
        end

        def custom_key?(key)
          CUSTOM_KEY_REGEX.match?(key) && !ContactJsnsBuilder::EXCLUDE_INSTANCE_VARIABLE_KEYS.include?(:"@#{key}")
        end

        def init_members_from_json(m, item)
          return if m.nil?

          item.members.all = m.map { |m| Zm::Client::ContactMember.new(m[:type], m[:value]) }
        end
      end
    end
  end
end
