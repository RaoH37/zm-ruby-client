# frozen_string_literal: true

module Zm
  module Client
    # Class Collection [Domain]
    class DomainsCollection < Base::ObjectsCollection
      def initialize(parent)
        @child_class = Domain
        @parent = parent
        reset_query_params
      end

      def find_by(hash, *attrs)
        rep = sac.get_domain(hash.values.first, hash.keys.first, attrs.join(COMMA))
        entry = rep[:Body][:GetDomainResponse][:domain].first

        build_from_entry(entry)
      end

      private

      def build_response
        DomainsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::DOMAIN
        @attrs = SearchType::Attributes::DOMAIN.dup
        @all_servers = 1
        @refresh = 0
        @apply_cos = 1
      end
    end
  end
end
