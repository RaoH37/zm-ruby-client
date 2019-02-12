module Zm
  module Client
    # Class Collection [Domain]
    class DomainsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def find_by(hash, *attrs)
        rep = sac.get_domain(hash.values.first, hash.keys.first, attrs.join(COMMA))
        entry = rep[:Body][:GetDomainResponse][:domain].first
        domain = Domain.new(@parent)
        domain.init_from_json(entry)
        domain
      end

      private

      def build_response
        DomainsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::DOMAIN
        @attrs = SearchType::Attributes::DOMAIN
      end
    end
  end
end
