# frozen_string_literal: true

module Zm
  module Model
    module AttributeChangeObserver
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def define_changed_attributes(*attr_names)
          attr_names.flatten.each { |attr_name| define_changed_attribute(attr_name) }
        end

        def define_changed_attribute(attr_name)
          attr_reader attr_name

          generated_attribute_methods.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{attr_name}_changed
              @#{attr_name}_changed ||= false
            end

            def #{attr_name}_changed?
              #{attr_name}_changed
            end

            def #{attr_name}=(value)
              return @#{attr_name} if value == @#{attr_name}
              @#{attr_name}_changed = true
              @#{attr_name} = value
            end
          RUBY
        end

        private

        def generated_attribute_methods
          @generated_attribute_methods ||= Module.new.tap { |mod| include mod }
        end
      end
    end
  end
end
