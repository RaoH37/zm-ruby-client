# frozen_string_literal: true

module Zm
  module Client
    module Base
      # declares the Zimbra LDAP attributes of an admin object: accessors, writable attributes list and changes tracking
      module HasZimbraAttributes
        def self.extended(base)
          base.include(InstanceMethods)
        end

        def zimbra_attr(*names, readonly: false)
          names = names.flatten.map!(&:to_sym).uniq
          readonly ? attr_accessor(*names) : define_tracked_accessors(names)

          added = zimbra_attrs_writable
          removed = zimbra_attrs_readonly
          added, removed = removed, added if readonly
          removed.reject! { |name| names.include?(name) }
          added.concat(names - added)

          @attrs_write = @attrs_write_ivars = @zimbra_attrs_ivars = nil
          names
        end

        def zimbra_attrs_writable
          @zimbra_attrs_writable ||= inherited_zimbra_attrs(:zimbra_attrs_writable)
        end

        def zimbra_attrs_readonly
          @zimbra_attrs_readonly ||= inherited_zimbra_attrs(:zimbra_attrs_readonly)
        end

        def zimbra_attrs
          zimbra_attrs_writable + zimbra_attrs_readonly
        end

        def attrs_write
          @attrs_write ||= zimbra_attrs_writable.map(&:name).freeze
        end

        def attrs_write_ivars
          @attrs_write_ivars ||= zimbra_attrs_writable.map { |name| :"@#{name}" }.freeze
        end

        def zimbra_attrs_ivars
          @zimbra_attrs_ivars ||= zimbra_attrs.to_h { |name| [name.name, :"@#{name}"] }.freeze
        end

        private

        def define_tracked_accessors(names)
          attr_reader(*names)

          names.each do |name|
            ivar = :"@#{name}"
            define_method(:"#{name}=") do |value|
              (@zimbra_attrs_changes ||= {})[name] = true
              instance_variable_set(ivar, value)
            end
          end
        end

        def inherited_zimbra_attrs(method)
          superclass.respond_to?(method) ? superclass.public_send(method).dup : []
        end

        # changes tracking of the writable Zimbra attributes, sent by modify!
        module InstanceMethods
          EMPTY_CHANGES = [].freeze

          def attrs_write
            self.class.attrs_write
          end

          def zimbra_attrs_changed
            @zimbra_attrs_changes.nil? ? EMPTY_CHANGES : @zimbra_attrs_changes.keys
          end

          def zimbra_attrs_changed?
            !@zimbra_attrs_changes.nil?
          end

          def zimbra_attr_changed?(name)
            !@zimbra_attrs_changes.nil? && @zimbra_attrs_changes.key?(name.to_sym)
          end

          def zimbra_attr_will_change!(name)
            name = name.to_sym
            raise ArgumentError, "#{name} is not a writable Zimbra attribute" unless attrs_write.include?(name.name)

            (@zimbra_attrs_changes ||= {})[name] = true
            self
          end

          def clear_zimbra_attrs_changes
            remove_instance_variable(:@zimbra_attrs_changes) if defined?(@zimbra_attrs_changes)
            self
          end

          private

          def zimbra_attrs_to_update(hash, force)
            hash.delete_if do |key, value|
              value.nil? || !respond_to?(key) || (!force && zimbra_attr_unchanged?(key, value))
            end
          end

          def zimbra_attr_unchanged?(key, value)
            ivar = self.class.zimbra_attrs_ivars[key.to_s]
            return false if ivar.nil? || zimbra_attr_changed?(key)

            current = instance_variable_get(ivar)
            current == value || same_zimbra_values?(current, value)
          end

          def same_zimbra_values?(current, value)
            current = Array(current)
            value = Array(value)
            current.size == value.size && current.each_with_index.all? { |item, i| item.to_s == value[i].to_s }
          end

          def forget_zimbra_attr_change(key)
            return if @zimbra_attrs_changes.nil?

            @zimbra_attrs_changes.delete(key.to_sym)
            clear_zimbra_attrs_changes if @zimbra_attrs_changes.empty?
          end
        end
      end
    end
  end
end
