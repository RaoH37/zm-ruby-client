# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::AccountObject
      include Zm::Model::AttributeChangeObserver

      attr_accessor :id

      define_changed_attributes :name, :color, :rgb

      def create!
        rep = @parent.sacc.jsns_request(:CreateTagRequest, @parent.token, jsns_builder.to_jsns)
        json = rep[:Body][:CreateTagResponse][:tag].first
        TagJsnsInitializer.update(self, json)
        super
      end

      def modify!
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_update) if color_changed? || rgb_changed?
      end

      private

      def do_update!(hash)
        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= TagJsnsBuilder.new(self)
      end
    end
  end
end
