# frozen_string_literal: true

module Zm
  module Client
    # collection account aces
    class AcesCollection < Base::AccountObjectsCollection
      attr_reader :rights

      def initialize(parent)
        super(parent)
        @child_class = Ace
        @builder_class = AcesBuilder
        @jsns_builder = AceJsnsBuilder.new(self)
        reset_query_params
      end

      # def new
      #   ace = Ace.new(self)
      #   yield(ace) if block_given?
      #   ace
      # end

      def where(*rights)
        @rights += rights
        @rights.uniq!
        self
      end

      # def soap_account_connector
      #   @parent.soap_account_connector
      # end
      #
      # alias sacc soap_account_connector

      private

      def make_query
        @parent.sacc.get_rights(@parent.token, @jsns_builder.to_find)
      end

      # def build_response
      #   @builder_class.new(self, make_query).make
      # end

      def reset_query_params
        @rights = []
      end
    end
  end
end
