# frozen_string_literal: true

require 'zm/modules/common/dl_common'
module Zm
  module Client
    # objectClass: zimbraDistributionList
    class DistributionList < Base::AdminObject
      attr_accessor :members

      def initialize(parent)
        extend(DistributionListCommon)
        super(parent)
        @members = []
        @grantee_type = 'grp'.freeze
      end

      def create!
        rep = sac.create_distribution_list(
          @name,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateDistributionListResponse][:dl].first[:id]
      end

      def aliases
        @aliases ||= []
      end

      def add_alias!(email)
        sac.add_distribution_list_alias(@id, email)
        aliases.push(email)
      end

      def remove_alias!(email)
        sac.remove_distribution_list_alias(@id, email)
        aliases.delete(email)
      end

      def rename!(email)
        sac.rename_distribution_list(@id, email)
        @name = email
      end

      def add_members!(*emails)
        sac.add_distribution_list_members(@id, emails)
        @members += emails
      end

      def remove_members!(*emails)
        sac.remove_distribution_list_members(@id, emails)
        @members -= emails
      end
    end
  end
end
