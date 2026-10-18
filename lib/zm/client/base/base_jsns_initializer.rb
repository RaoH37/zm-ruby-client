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

            formatted_json(json).each do |k, v|
              valorise(item, k, v)
            end

            item
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
