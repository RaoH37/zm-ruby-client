# frozen_string_literal: true

module Zm
  module Client
    module Base
      # declares the Zimbra LDAP attributes of an admin object: accessors and writable attributes list
      module HasZimbraAttributes
        def self.extended(base)
          base.define_method(:attrs_write) { self.class.attrs_write }
        end

        def zimbra_attr(*names, readonly: false)
          names = names.flatten.map!(&:to_sym).uniq
          attr_accessor(*names)

          added = zimbra_attrs_writable
          removed = zimbra_attrs_readonly
          added, removed = removed, added if readonly
          removed.reject! { |name| names.include?(name) }
          added.concat(names - added)

          @attrs_write = @attrs_write_ivars = nil
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

        private

        def inherited_zimbra_attrs(method)
          superclass.respond_to?(method) ? superclass.public_send(method).dup : []
        end
      end
    end
  end
end
