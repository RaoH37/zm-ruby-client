# frozen_string_literal: true

module Zm
  module Client
    module Base
      # class for account object jsns initializer
      class BaseJsnsInitializer
        INTEGER_REGEX = /\A(?:0|-?[1-9]\d*)\z/
        SETTERS = Hash.new { |h, name| h[name] = :"#{name}=" }

        class << self
          def create(parent, json)
            klass.new(parent).tap do |item|
              update(item, json)
            end
          end

          def update(item, json)
            item.id = json.delete(:id)
            item.name = json.delete(:name)

            nodes = json[:a]
            return item if nodes.nil?

            ivars = item.class.zimbra_attrs_ivars if item.class.respond_to?(:zimbra_attrs_ivars)
            each_attribute(nodes) { |key, value| assign(item, ivars, key, value) }

            item
          end

          # Zimbra sends the values of a multi-valued attribute one after the other
          def each_attribute(nodes)
            key = value = nil
            multi = false

            nodes.each do |node|
              name = node[:n]
              next if name.nil?

              if name == key
                value = [value] unless multi
                multi = true
                value << node[:_content]
              else
                yield(key, value) unless key.nil?
                key = name
                value = node[:_content]
                multi = false
              end
            end

            yield(key, value) unless key.nil?
          end

          def assign(item, ivars, key, value)
            ivar = ivars&.[](key)
            ivar ? item.instance_variable_set(ivar, convert_json_string_value(value)) : valorise(item, key, value)
          end

          def formatted_json(json)
            return [] if json[:a].nil?

            json[:a].each_with_object({}) do |n, h|
              add_value(h, n[:n], n[:_content]) unless n[:n].nil?
            end
          end

          def add_value(hash, key, value)
            current = hash.fetch(key, hash)

            if current.equal?(hash)
              hash[key] = value
            elsif current.is_a?(Array)
              current << value
            else
              hash[key] = [current, value]
            end
          end

          def valorise(item, k, v)
            setter = SETTERS[k]
            return unless item.respond_to?(setter)

            item.send(setter, convert_json_string_value(v))
          end

          def convert_json_string_value(value)
            return value unless value.is_a?(String) && INTEGER_REGEX.match?(value)

            value.to_i
          end
        end
      end
    end
  end
end
