# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning Object
      class Object
        attr_accessor :parent, :token, :name, :id
        attr_reader :grantee_type

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def init_from_json(json)
          @id    = json[:id]
          @name  = json[:name]
        end

        def convert_json_string_value(value)
          return value unless value.is_a?(String)
          return 0 if value == '0'

          c = value.to_i
          c.to_s == value ? c : value
        end

        def recorded?
          !@id.nil?
        end

        def save!
          recorded? ? modify! : create!
        end

        def instance_variables_array(zcs_attrs)
          selected_attrs = zcs_attrs.map { |a| Utils.arrow_name_sym(a) }
          attrs_only_set = instance_variables & selected_attrs

          arr = attrs_only_set.map do |name|
            n = name.to_s[1..]
            value = instance_variable_get(name)
            [n, value]
          end

          multi_value = arr.select { |a| a.last.is_a?(Array) }
          arr.reject! { |a| a.last.is_a?(Array) }
          multi_value.each { |a| arr += a.last.map { |v| [a.first, v] } }
          arr
        end

        def instance_variables_hash(zcs_attrs)
          Hash[instance_variables_array(zcs_attrs)]
        end

        def clone
          obj = super
          obj.remove_instance_variable(:@id)
          yield(obj) if block_given?
          obj
        end

        def logger
          @parent.logger
        end

        def update_attribute(key, value)
          arrow_attr_sym = Utils.arrow_name_sym(key)

          if value.respond_to?(:empty?) && value.empty?
            remove_instance_variable(arrow_attr_sym) if instance_variable_get(arrow_attr_sym)
          else
            instance_variable_set(arrow_attr_sym, value)
          end
        end

        def to_s
          inspect
        end

        def to_h
          Hash[instance_variables_map]
        end

        def inspect
          keys_str = to_h.map { |k, v| "#{k}: #{v}" }.join(', ')
          "#{self.class}:#{format('0x00%x', (object_id << 1))} #{keys_str}"
        end

        def instance_variables_map
          keys = instance_variables.dup
          keys.delete(:@parent)
          keys.map { |key| [key, instance_variable_get(key)] }
        end
      end
    end
  end
end
