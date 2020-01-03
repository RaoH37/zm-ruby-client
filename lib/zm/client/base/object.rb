# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning Object
      class Object
        attr_accessor :token, :name, :id

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def init_from_json(json)
          @id    = json[:id]
          @name  = json[:name]
        end

        def concat
          instance_variables.map { |variable| instance_variable_get(variable) }
        end

        def to_s
          concat.join(DOUBLEPOINT)
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
          selected_attrs = zcs_attrs.map { |a| arrow_name(a).to_sym }
          attrs_only_set = instance_variables & selected_attrs
          attrs_only_set.map do |name|
            [name.to_s[1..-1], instance_variable_get(name)]
          end
        end

        def instance_variables_hash(zcs_attrs)
          Hash[instance_variables_array(zcs_attrs)]
        end

        def arrow_name(name)
          "@#{name}"
        end
      end
    end
  end
end
