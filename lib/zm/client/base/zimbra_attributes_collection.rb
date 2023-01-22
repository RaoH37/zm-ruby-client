# frozen_string_literal: true

require 'zm/client/base/zimbra_attribute'

module Zm
  module Client
    module Base
      class ZimbraAttributesCollection
        ZIMBRA_ATTRS_PATH = "#{File.dirname(__FILE__)}../../../modules/common/zimbra-attrs.json"

        attr_reader :all, :all_versioned

        def initialize(parent)
          @parent = parent

          @all = JSON.parse(File.read(File.expand_path(ZIMBRA_ATTRS_PATH)),
                            object_class: ZimbraAttribute).select do |attr|
            attr.version_start == @parent.version || VersionSorter.sort([@parent.version,
                                                                         attr.version_start]).first != @parent.version
          end.freeze
        end

        def set_methods
          set_server_methods
          set_cos_methods
          set_domain_methods
          set_account_methods
          set_distributionlist_methods
          set_resource_methods
        end

        # ###############################
        # Cos
        # ###############################

        def all_cos_attrs
          @all_cos_attrs ||= @all.select(&:is_cos_scoped?).freeze
        end

        def all_cos_attrs_writable
          @all_cos_attrs_writable ||= all_cos_attrs.reject(&:immutable?).freeze
        end

        def all_cos_attrs_writable_names
          @all_cos_attrs_writable_names ||= all_cos_attrs_writable.map(&:name).freeze
        end

        def all_cos_attr_types_h
          @all_cos_attr_types_h ||= Hash[all_cos_attrs.map { |attr| [attr.name, attr.type] }].freeze
        end

        def set_cos_methods
          Cos.attr_accessor(*all_cos_attrs.map { |attr| attr.name.to_sym })
        end

        # ###############################
        # Server
        # ###############################

        def all_server_attrs
          @all_server_attrs ||= @all.select(&:is_server_scoped?).freeze
        end

        def all_server_attrs_writable
          @all_server_attrs_writable ||= all_server_attrs.reject(&:immutable?).freeze
        end

        def all_server_attrs_writable_names
          @all_server_attrs_writable_names ||= all_server_attrs_writable.map(&:name).freeze
        end

        def all_server_attr_types_h
          @all_server_attr_types_h ||= Hash[all_server_attrs.map { |attr| [attr.name, attr.type] }].freeze
        end

        def set_server_methods
          Server.attr_accessor(*all_server_attrs.map { |attr| attr.name.to_sym })
        end

        # ###############################
        # Domain
        # ###############################

        def all_domain_attrs
          @all_domain_attrs ||= @all.select(&:is_domain_scoped?).freeze
        end

        def all_domain_attrs_writable
          @all_domain_attrs_writable ||= all_domain_attrs.reject(&:immutable?).freeze
        end

        def all_domain_attrs_writable_names
          @all_domain_attrs_writable_names ||= all_domain_attrs_writable.map(&:name).freeze
        end

        def all_domain_attr_types_h
          @all_domain_attr_types_h ||= Hash[all_domain_attrs.map { |attr| [attr.name, attr.type] }].freeze
        end

        def set_domain_methods
          Domain.attr_accessor(*all_domain_attrs.map { |attr| attr.name.to_sym })
        end

        # ###############################
        # Account
        # ###############################

        def all_account_attrs
          @all_account_attrs ||= @all.select { |attr| attr.is_account_scoped? || attr.is_mailRecipient_scoped? }.freeze
        end

        def all_account_attrs_writable
          @all_account_attrs_writable ||= all_account_attrs.reject(&:immutable?).freeze
        end

        def all_account_attrs_writable_names
          @all_account_attrs_writable_names ||= all_account_attrs_writable.map(&:name).freeze
        end

        def all_account_attr_types_h
          @all_account_attr_types_h ||= Hash[all_account_attrs.map { |attr| [attr.name, attr.type] }].freeze
        end

        def set_account_methods
          Account.attr_accessor(*all_account_attrs.map { |attr| attr.name.to_sym })
        end

        # ###############################
        # Distribution List
        # ###############################

        def all_distributionlist_attrs
          @all_distributionlist_attrs ||= @all.select do |attr|
            attr.is_distributionList_scoped? || attr.is_group_scoped? || attr.is_groupDynamicUnit_scoped?
          end.freeze
        end

        def all_distributionlist_attrs_writable
          @all_distributionlist_attrs_writable ||= all_distributionlist_attrs.reject(&:immutable?).freeze
        end

        def all_distributionlist_attrs_writable_names
          @all_distributionlist_attrs_writable_names ||= all_distributionlist_attrs_writable.map(&:name).freeze
        end

        def all_distributionlist_attrs_types_h
          @all_distributionlist_attrs_types_h ||= Hash[all_distributionlist_attrs.map do |attr|
                                                         [attr.name, attr.type]
                                                       end].freeze
        end

        def set_distributionlist_methods
          DistributionList.attr_accessor(*all_distributionlist_attrs.map { |attr| attr.name.to_sym })
        end

        # ###############################
        # Calendar Resource
        # ###############################

        def all_resource_attrs
          @all_resource_attrs ||= @all.select(&:is_calendarResource_scoped?).freeze
        end

        def all_resource_attrs_writable
          @all_resource_attrs_writable ||= all_resource_attrs.reject(&:immutable?).freeze
        end

        def all_resource_attrs_writable_names
          @all_resource_attrs_writable_names ||= all_resource_attrs_writable.map(&:name).freeze
        end

        def all_resource_attrs_types_h
          @all_resource_attrs_types_h ||= Hash[all_resource_attrs.map { |attr| [attr.name, attr.type] }].freeze
        end

        def set_resource_methods
          Resource.attr_accessor(*all_resource_attrs.map { |attr| attr.name.to_sym })
        end
      end
    end
  end
end
