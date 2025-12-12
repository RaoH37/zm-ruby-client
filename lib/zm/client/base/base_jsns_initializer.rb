# frozen_string_literal: true

module Zm
  module Client
    module Base
      # class for account object jsns initializer
      class BaseJsnsInitializer
        class << self
          def update(item, json)
            item.id = json[:id]
            item.name = json[:name]

            formatted_json(json).each do |k, v|
              valorise(item, k, v)
            end

            item
          end

          def formatted_json(json)
            return [] if json[:a].nil?

            json[:a].reject! { |n| n[:n].nil? }
            json_map = json[:a].map { |n| [n[:n], n[:_content]] }.freeze

            hash_multivalued = json_map.each_with_object({}) do |(k, v), h|
              h[k] ||= []
              h[k].push(v)
            end

            hash_multivalued.transform_values do |v|
              v.length == 1 ? v.first : v
            end
          end

          def valorise(item, k, v)
            setter_method_name = "#{k}="
            return unless item.respond_to?(setter_method_name)

            item.send(setter_method_name, convert_json_string_value(v))
          end

          def convert_json_string_value(value)
            return value unless value.is_a?(String)
            return 0 if value == '0'

            c = value.to_i
            c.to_s == value ? c : value
          end
        end
      end
    end
  end
end
