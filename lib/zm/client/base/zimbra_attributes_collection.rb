# frozen_string_literal: true

require 'zm/client/base/zimbra_attribute'

module Zm
  module Client
    module Base
      class ZimbraAttributesCollection
        attr_reader :all

        def initialize(parent)
          @parent = parent
          @all = JSON.parse(File.read(File.expand_path(File.dirname(__FILE__) + '../../../modules/common/zimbra-attrs.json')), object_class: ZimbraAttribute).freeze
        end

        def set_methods
          all_account_attrs = all_account_attrs_version(@parent.version)
          Account.attr_reader *all_account_attrs.select { |attr| attr.immutable }.map { |attr| attr.name.to_sym }
          Account.attr_accessor *all_account_attrs.reject { |attr| attr.immutable }.map { |attr| attr.name.to_sym }
        end

        def all_account_attrs
          @all_account_attrs ||= @all.select { |attr| attr.is_account_scoped? }.freeze
        end

        def all_account_attr_types_h
          @all_account_attr_types_h ||= Hash[all_account_attrs.map { |attr| [attr.name, attr.type] }].freeze
        end

        # retourne tous les attributs qui ont une version
        # inférieure ou égale à la version données en paramètre
        def all_account_attrs_version(version)
          all_account_attrs.select { |attr| attr.version_start == version || VersionSorter.sort([version, attr.version_start]).first != version }
        end
      end
    end
  end
end
