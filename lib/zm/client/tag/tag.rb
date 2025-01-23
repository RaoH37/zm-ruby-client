# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::Object
      # include Zm::Model::AttributeChangeObserver

      attr_accessor :id, :name, :color, :rgb

      # define_changed_attributes :name, :color, :rgb

      def create!
        rep = @parent.sacc.invoke(build_create)
        json = rep[:CreateTagResponse][:tag].first
        TagJsnsInitializer.update(self, json)
        @id
      end

      def build_create
        jsns_builder.to_jsns
      end

      def modify!
        @parent.sacc.invoke(build_modify)
        true
      end

      def build_modify
        jsns_builder.to_update
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        do_update!(hash)

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def rename!(new_name)
        return false if new_name == @name

        @parent.sacc.invoke(build_rename(new_name))
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.invoke(build_delete)
        @id = nil
      end

      def build_delete
        jsns_builder.to_delete
      end

      private

      def do_update!(hash)
        @parent.sacc.invoke(jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= TagJsnsBuilder.new(self)
      end
    end
  end
end
