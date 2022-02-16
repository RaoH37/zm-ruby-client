# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::AccountObject
      include Zm::Model::AttributeChangeObserver

      INSTANCE_VARIABLE_KEYS = %i[id name color rgb]

      attr_accessor :id

      define_changed_attributes :name, :color, :rgb

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def create!
        rep = @parent.sacc.create_tag(@parent.token, jsns_builder.to_jsns)
        json = rep[:Body][:CreateTagResponse][:tag].first
        TagJsnsInitializer.update(self, json)
        super
      end

      def modify!
        @parent.sacc.tag_action(@parent.token, jsns_builder.to_update) if color_changed? || rgb_changed?
        super
      end

      def update!(hash)
        # todo
      end

      def delete!
        @parent.sacc.tag_action(@parent.token, jsns_builder.to_delete)
        super
      end

      def rename!
        @parent.sacc.tag_action(@parent.token, jsns_builder.to_rename) if name_changed?
        super
      end

      private

      def jsns_builder
        @jsns_builder ||= TagJsnsBuilder.new(self)
      end
    end
  end
end
