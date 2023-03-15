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
          # @use_builder = true
          yield(self) if block_given?
        end

        # def disable_builder
        #   @use_builder = false
        #   self
        # end
        #
        # def enable_builder
        #   @use_builder = true
        #   self
        # end
        #
        # def use_builder?
        #   @use_builder
        # end

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

        def arrow_name(name)
          return name if name.to_s.start_with?('@')

          "@#{name}"
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
      end
    end
  end
end
