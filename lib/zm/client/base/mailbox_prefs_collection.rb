# frozen_string_literal: true

module Zm
  module Client
    class MailboxPrefsCollection
      def initialize(parent)
        @parent = parent
        @preferences = []
      end

      def all
        @all || all!
      end

      def all!
        build_response
      end

      def clear
        reset_query_params
        @all.clear
      end

      def preferences(*entries)
        entries.flatten!
        @preferences += entries
        self
      end

      def update!(hash)
        # The JSON version is different:
        # {
        #   ModifyPrefsRequest: {
        #     "_attrs": {
        #       "prefName1": "prefValue1",
        #       "prefName2": "prefValue2"
        #       "+nameOfMulitValuedPref3": "addedPrefValue3",
        #       "-nameOfMulitValuedPref4": "removedPrefValue4",
        #       "nameOfMulitValuedPref5": ["prefValue5one","prefValue5two"],
        #       ...
        #     },
        #     _jsns: "urn:zimbraAccount"
        #   }
        # }

        req = {
          _attrs: hash
        }

        soap_request = SoapElement.account(SoapAccountConstants::MODIFY_PREFS_REQUEST).add_attributes(req)
        @parent.sacc.invoke(soap_request)
      end

      private

      def build_response
        @all = make_query.dig(:GetPrefsResponse, :_attrs)
      end

      def make_query
        soap_request = SoapElement.account(SoapAccountConstants::GET_PREFS_REQUEST).add_attributes(jsns)
        @parent.sacc.invoke(soap_request)
      end

      def jsns
        return nil if @preferences.empty?

        { prefs: @preferences.map { |name| { name: name } } }
      end

      def reset_query_params
        @preferences.clear
      end
    end
  end
end
