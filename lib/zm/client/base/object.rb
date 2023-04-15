# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning Object
      class Object
        attr_accessor :parent, :token, :name, :id

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def recorded?
          !@id.nil?
        end

        def save!
          recorded? ? modify! : create!
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
