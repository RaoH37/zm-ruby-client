# frozen_string_literal: true

require 'time'

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AdminObject
      class AdminObject < Object
        def soap_admin_connector
          @parent.soap_admin_connector
        end

        alias sac soap_admin_connector

        def update!(hash)
          return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

          do_update!(hash)

          hash.each do |key, value|
            update_attribute(key, value)
          end

          true
        end
      end
    end
  end
end
