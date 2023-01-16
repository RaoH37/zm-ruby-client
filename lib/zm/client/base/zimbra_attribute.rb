# frozen_string_literal: true

require 'ostruct'
require 'version_sorter'

module Zm
  module Client
    module Base
      class ZimbraAttribute < OpenStruct

        def version_start
          return @version_start unless @version_start.nil?

          if since.nil?
            @version_start = '0.0.0'
          else
            @version_start = VersionSorter.sort(since.split(',')).first
          end

          @version_start
        end

        def immutable?
          @immutable.to_s == '1'
        end

        def objects_scope
          @objects_scope ||= (optionalIn.to_s.split(',') + requiredIn.to_s.split(',')).freeze
        end

        def is_account_scoped?
          @is_account_scoped ||= objects_scope.include?('account')
        end

        def is_aclTarget_scoped?
          @is_aclTarget_scoped ||= objects_scope.include?('aclTarget')
        end

        def is_alias_scoped?
          @is_alias_scoped ||= objects_scope.include?('alias')
        end

        def is_alwaysOnCluster_scoped?
          @is_alwaysOnCluster_scoped ||= objects_scope.include?('alwaysOnCluster')
        end

        def is_calendarResource_scoped?
          @is_calendarResource_scoped ||= objects_scope.include?('calendarResource')
        end

        def is_cos_scoped?
          @is_cos_scoped ||= objects_scope.include?('cos')
        end

        def is_dataSource_scoped?
          @is_dataSource_scoped ||= objects_scope.include?('dataSource')
        end

        def is_distributionList_scoped?
          @is_distributionList_scoped ||= objects_scope.include?('distributionList')
        end

        def is_domain_scoped?
          @is_domain_scoped ||= objects_scope.include?('domain')
        end

        def is_globalConfig_scoped?
          @is_globalConfig_scoped ||= objects_scope.include?('globalConfig')
        end

        def is_group_scoped?
          @is_group_scoped ||= objects_scope.include?('group')
        end

        def is_groupDynamicUnit_scoped?
          @is_groupDynamicUnit_scoped ||= objects_scope.include?('groupDynamicUnit')
        end

        def is_groupStaticUnit_scoped?
          @is_groupStaticUnit_scoped ||= objects_scope.include?('groupStaticUnit')
        end

        def is_identity_scoped?
          @is_identity_scoped ||= objects_scope.include?('identity')
        end

        def is_mailRecipient_scoped?
          @is_mailRecipient_scoped ||= objects_scope.include?('mailRecipient')
        end

        def is_mimeEntry_scoped?
          @is_mimeEntry_scoped ||= objects_scope.include?('mimeEntry')
        end

        def is_objectEntry_scoped?
          @is_objectEntry_scoped ||= objects_scope.include?('objectEntry')
        end

        def is_server_scoped?
          @is_server_scoped ||= objects_scope.include?('server')
        end

        def is_signature_scoped?
          @is_signature_scoped ||= objects_scope.include?('signature')
        end

        def is_ucService_scoped?
          @is_ucService_scoped ||= objects_scope.include?('ucService')
        end

        def is_xmppComponent_scoped?
          @is_xmppComponent_scoped ||= objects_scope.include?('xmppComponent')
        end

        def is_zimletEntry_scoped?
          @is_zimletEntry_scoped ||= objects_scope.include?('zimletEntry')
        end
      end
    end
  end
end
