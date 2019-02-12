module Zm
  module Client
    # class factory [accounts]
    class AccountsBuilder < Base::ObjectsBuilder
      def make
        records = []
        return records if json_items.nil?

        json_items.each do |entry|
          account = Account.new(@parent)
          account.init_from_json(entry)
          records << account
        end
        records
      end

      private

      def json_items
        @json_items ||= @json[:Body][json_key][:account]
      end
    end
  end
end
