# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AccountObject
      class AccountObject < Object
        def create!
          @id
        end

        def modify!
          rename!
          true
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

          @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_rename(new_name))
          @name = new_name
        end

        def delete!
          return false if @id.nil?

          @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_delete)
          @id = nil
        end
      end
    end
  end
end
