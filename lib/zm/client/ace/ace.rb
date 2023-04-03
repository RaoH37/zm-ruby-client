# frozen_string_literal: true

module Zm
  module Client
    # class account ace
    class Ace < Base::Object
      attr_accessor :zid, :gt, :right, :d

      def create!
        rep = @parent.sacc.jsns_request(:GrantRightsRequest, @arent.token, jsns_builder.to_jsns,
                                        SoapAccountConnector::ACCOUNTSPACE)

        json = rep[:Body][:GrantRightsResponse][:ace].first if rep[:Body][:GrantRightsResponse][:ace].is_a?(Array)
        AceJsnsInitializer.update(self, json) unless json.nil?
        true
      end

      def delete!
        @parent.sacc.jsns_request(:RevokeRightsRequest, @arent.token, jsns_builder.to_delete,
                                  SoapAccountConnector::ACCOUNTSPACE)
        @parent.all.delete(self)
        true
      end

      private

      def jsns_builder
        @jsns_builder ||= AceJsnsBuilder.new(self)
      end
    end
  end
end
