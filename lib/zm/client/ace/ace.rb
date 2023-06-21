# frozen_string_literal: true

module Zm
  module Client
    # class account ace
    class Ace < Base::Object
      attr_accessor :zid, :gt, :right, :d

      def create!
        rep = @parent.sacc.invoke(jsns_builder.to_jsns)

        json = rep[:GrantRightsResponse][:ace].first if rep[:GrantRightsResponse][:ace].is_a?(Array)
        AceJsnsInitializer.update(self, json) unless json.nil?
        true
      end

      def delete!
        @parent.sacc.invoke(jsns_builder.to_delete)
        true
      end

      private

      def jsns_builder
        @jsns_builder ||= AceJsnsBuilder.new(self)
      end
    end
  end
end
