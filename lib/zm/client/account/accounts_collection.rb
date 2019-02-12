module Zm
  module Client
    # Collection Accounts
    class AccountsCollection < Base::ObjectsCollection
      def initialize(parent)
        @parent = parent
        reset_query_params
      end

      def find_by(hash, *attrs)
        rep = sac.get_account(hash.values.first, hash.keys.first, attrs.join(COMMA))
        entry = rep[:Body][:GetAccountResponse][:domain].first
        account = Account.new(@parent)
        account.init_from_json(entry)
        account
      end

      private

      # def domain_name
      #   @domain.nil? ? nil : @domain.name
      # end

      def build_response
        AccountsBuilder.new(@parent, make_query).make
      end

      def reset_query_params
        super
        @search_type = SearchType::ACCOUNT
        @attrs = SearchType::Attributes::ACCOUNT
      end
    end
  end
end
