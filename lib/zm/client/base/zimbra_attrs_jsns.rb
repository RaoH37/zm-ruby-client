# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Zimbra attributes of an admin object as jsns values: all the set ones (create) or the changed ones (modify)
      module ZimbraAttrsJsns
        CLEARED_VALUES = [''].freeze

        def attrs_only_set_h
          selected_attrs = @item.class.attrs_write_ivars
          attrs_only_set = @item.instance_variables & selected_attrs

          attrs_only_set.to_h do |name|
            values = @item.instance_variable_get(name)
            values = [values] unless values.is_a?(Array)
            [name.name[1..], values]
          end
        end

        def attrs_changed_h
          ivars = @item.class.zimbra_attrs_ivars

          @item.zimbra_attrs_changed.to_h do |name|
            key = name.name
            [key, changed_values(@item.instance_variable_get(ivars[key]))]
          end
        end

        def attrs_to_update_h(force)
          force ? attrs_only_set_h : attrs_changed_h
        end

        private

        def changed_values(values)
          return CLEARED_VALUES if values.nil? || (values.is_a?(Array) && values.empty?)

          values.is_a?(Array) ? values : [values]
        end
      end
    end
  end
end
