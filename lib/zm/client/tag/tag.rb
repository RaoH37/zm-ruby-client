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
        hash.delete_if { |k, v| v.nil? || !respond_to?(k) }
        return false if hash.empty?

        @parent.sacc.tag_action(@parent.token, jsns_builder.to_patch(hash))

        hash.each do |k, v|
          arrow_attr_sym = "@#{k}".to_sym

          if v.respond_to?(:empty?) && v.empty?
            remove_instance_variable(arrow_attr_sym) if instance_variable_get(arrow_attr_sym)
          else
            instance_variable_set(arrow_attr_sym, v)
          end
        end

        true
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
