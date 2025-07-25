# frozen_string_literal: true

module Zm
  module Client
    module RequestMethodsMailbox
      def build_create
        jsns_builder.to_jsns
      end

      def modify!
        @parent.soap_connector.invoke(build_modify)
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

        @parent.soap_connector.invoke(build_rename(new_name))
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      def delete!
        return false if @id.nil?

        @parent.soap_connector.invoke(build_delete)
        @id = nil
      end

      def build_delete
        jsns_builder.to_delete
      end

      private def do_update!(hash)
        @parent.soap_connector.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
