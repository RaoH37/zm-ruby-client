# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class DomainsCollection < Base::AdminObjectsCollection
      def initialize(parent)
        @child_class = Domain
        @builder_class = DomainsBuilder
        @search_type = SearchType::DOMAIN
        super(parent)
      end

      def find_by(hash)
        rep = sac.get_domain(hash.values.first, hash.keys.first, attrs_comma)
        entry = rep[:Body][:GetDomainResponse][:domain].first

        reset_query_params
        # build_from_entry(entry)
        DomainJsnsInitializer.create(@parent, entry)
      end

      private

      def reset_query_params
        super
        @attrs = SearchType::Attributes::DOMAIN.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
