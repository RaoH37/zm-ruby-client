# frozen_string_literal: true

module Zm
  module Client
    module RequestMethodsAdmin
      def delete!
        sac.invoke(build_delete)
        @id = nil
      end

      def build_delete
        jsns_builder.to_delete
      end

      def modify!
        sac.invoke(build_modify)
        true
      end

      def build_modify
        jsns_builder.to_update
      end

      def build_create
        jsns_builder.to_create
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
        sac.invoke(build_rename(new_name))
        @name = new_name
      end

      def build_rename(new_name)
        jsns_builder.to_rename(new_name)
      end

      private

      def do_update!(hash)
        sac.invoke(jsns_builder.to_patch(hash))
      end
    end
  end
end
