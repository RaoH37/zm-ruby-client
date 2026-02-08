# frozen_string_literal: true

module ZM
  module Client
    module ModGroupContact
      def members
        return @members if defined? @members

        @members = Zm::Client::ContactMembersCollection.new(self)
      end

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = Zm::Client::GroupContactJsnsBuilder.new(self)
      end
    end
  end
end
