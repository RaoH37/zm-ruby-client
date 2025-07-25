# frozen_string_literal: true

module Zm
  module Client
    # collection account aces
    class AcesCollection < Base::AccountObjectsCollection
      attr_reader :rights

      def new_from_object(item, right)
        case item
        when Account
          zid = item.id
          gt = Ace::GT_USER
        when Resource
          zid = item.id
          gt = Ace::GT_USER
        when DistributionList
          zid = item.id
          gt = Ace::GT_GROUP
        when Domain
          zid = item.id
          gt = Ace::GT_DOMAIN
        else
          zid = nil
          gt = nil
        end

        new do |ace|
          ace.zid = zid
          ace.gt = gt
          ace.right = right
        end
      end

      def create_from_object(item, right)
        ace = new_from_object(item, right)
        add(ace)
        ace
      end

      def add(ace)
        @all << ace
      end

      def initialize(parent)
        super(parent)
        @child_class = Ace
        @builder_class = AcesBuilder
        @jsns_builder = AceJsnsBuilder.new(self)
        reset_query_params
      end

      def where(*rights)
        rights.flatten!
        @rights += rights
        @rights.uniq!
        self
      end

      private

      def make_query
        # @parent.sacc.invoke(@jsns_builder.to_find)
        @parent.soap_connector.invoke(@jsns_builder.to_find)
      end

      def reset_query_params
        @rights = []
      end
    end
  end
end
