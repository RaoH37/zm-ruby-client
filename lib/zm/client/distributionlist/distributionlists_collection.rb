# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class DistributionListsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def ldap
        @apply_cos = 0
        self
      end

      def find_by(hash)
        rep = sac.get_distribution_list(hash.values.first, hash.keys.first, attrs_comma)
        entry = rep[:Body][:GetDistributionListResponse][:dl].first
        dl = DistributionList.new(@parent)
        dl.init_from_json(entry)
        dl
      end

      private

      def build_response
        DistributionListsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::DL
        @attrs = SearchType::Attributes::DL.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
