# frozen_string_literal: true

module Zm
  module Client
    module Base
      # deprecated: attributes are declared in each class with zimbra_attr, will be removed in 4.0
      class ZimbraAttributesCollection
        include Zm::Utils::MissingMethodStaticCollection

        MUTEX = Mutex.new
        OBJECTS = {
          account: [:Account, 'account'],
          cos: [:Cos, 'cos'],
          domain: [:Domain, 'domain'],
          server: [:Server, 'server'],
          distributionlist: [:DistributionList, 'distributionList'],
          resource: [:Resource, 'calendarResource']
        }.freeze

        class << self
          def shared(_parent = nil)
            MUTEX.synchronize { @shared ||= new }
          end
        end

        def initialize(_parent = nil)
          readonly = readonly_names
          @all = object_scopes.map { |name, scope| build_attribute(name, scope, readonly.include?(name)) }.freeze
          @by_name = @all.to_h { |attr| [attr.name, attr] }
          @by_object = {}
        end

        def path
          nil
        end

        def set_methods; end

        OBJECTS.each do |object, (class_name, _scope)|
          define_method(:"all_#{object}_attrs") do
            @by_object[object] ||= Client.const_get(class_name).zimbra_attrs.map { |name| @by_name[name.name] }.freeze
          end

          define_method(:"all_#{object}_attrs_writable") do
            send(:"all_#{object}_attrs").reject(&:immutable?)
          end

          define_method(:"all_#{object}_attrs_writable_names") { Client.const_get(class_name).attrs_write }

          define_method(:"all_#{object}_attrs_types_h") do
            send(:"all_#{object}_attrs").to_h { |attr| [attr.name, attr.type] }
          end

          define_method(:"set_#{object}_methods") { nil }
        end

        alias all_account_attr_types_h all_account_attrs_types_h
        alias all_cos_attr_types_h all_cos_attrs_types_h
        alias all_domain_attr_types_h all_domain_attrs_types_h
        alias all_server_attr_types_h all_server_attrs_types_h

        private

        def object_scopes
          OBJECTS.each_value.with_object(Hash.new { |hash, name| hash[name] = [] }) do |(class_name, scope), scopes|
            Client.const_get(class_name).zimbra_attrs.each { |name| scopes[name] << scope }
          end
        end

        def readonly_names
          OBJECTS.each_value.flat_map { |class_name, _scope| Client.const_get(class_name).zimbra_attrs_readonly }.to_set
        end

        def build_attribute(name, scope, immutable)
          ZimbraAttribute.new(name: name.name, optionalIn: scope.join(','), immutable: immutable ? '1' : nil)
        end
      end
    end
  end
end
