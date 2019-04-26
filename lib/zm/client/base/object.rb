module Zm
  module Client
    module Base
      # Abstract Class Provisionning Object
      class Object
        attr_accessor :token, :name, :id, :cn, :zimbraZimletAvailableZimlets

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def soap_admin_connector
          @parent.soap_admin_connector
        end

        alias sac soap_admin_connector

        def soap_account_connector
          @parent.soap_account_connector
        end

        alias sacc soap_account_connector

        def concat
          instance_variables.map { |variable| instance_variable_get(variable) }
        end

        def to_s
          concat.join(' :: ')
        end

        def init_from_json(json)
          @id    = json[:id]
          @name  = json[:name]
          # todo : attention cette condition est uniquement valable pour les compte et doit être déplacée !!!
          return unless json[:a].is_a? Array

          # fix car le tableau peut contenir des {} vide !
          json[:a].reject! { |n| n[:n].nil? }
          json_map = json[:a].map { |n| ["@#{n[:n]}", n[:_content]] }.freeze

          Hash[json_map].each do |k, v|
            instance_variable_set(k, convert_json_string_value(v))
          end
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
          selected_attrs = zcs_attrs.map { |a| "@#{a}".to_sym }
          attrs_only_set = instance_variables & selected_attrs
          attrs_only_set.map do |name|
            [name.to_s[1..-1], instance_variable_get(name)]
          end
        end

        def instance_variables_hash(zcs_attrs)
          Hash[instance_variables_array(zcs_attrs)]
        end
      end
    end
  end
end
