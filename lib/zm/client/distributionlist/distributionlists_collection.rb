# frozen_string_literal: true

module Zm
  module Client
    # Collection Resources
    class DistributionListsCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = DistributionList
        @builder_class = DistributionListsBuilder
        @search_type = SearchType::DL
        @parent = parent
        reset_query_params
      end

      def find_by(hash)
        rep = sac.get_distribution_list(hash.values.first, hash.keys.first, attrs_comma)
        entry = rep[:Body][:GetDistributionListResponse][:dl].first

        reset_query_params
        build_from_entry(entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::DL.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
