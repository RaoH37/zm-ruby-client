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

        def soap_account_connector
          @soap_account_connector || soap_account_connector!
        end

        def soap_account_connector!
          @soap_account_connector = SoapAccountConnector.create(@parent)
        end

        alias sacc soap_account_connector

        def init_from_json(json)
          super(json)
          return unless json[:a].is_a? Array

          # fix car le tableau peut contenir des {} vide !
          json[:a].reject! { |n| n[:n].nil? }
          json_map = json[:a].map { |n| ["@#{n[:n]}", n[:_content]] }.freeze

          json_hash = json_map.each_with_object({}) do |(k, v), h|
                        (h[k] ||= [])
                        h[k].push(v)
                      end.transform_values do |v|
            v.length == 1 ? v.first : v
          end

          json_hash.each do |k, v|
            instance_variable_set(k, convert_json_string_value(v))
          end
        end

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
