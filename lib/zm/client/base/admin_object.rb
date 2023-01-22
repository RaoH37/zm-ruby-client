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
          @parent.soap_account_connector
        end

        alias sacc soap_account_connector

        def to_h
          hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
          hashmap.delete_if { |_, v| v.nil? }
          hashmap
        end

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

          # Hash[json_map].each do |k, v|
          #   instance_variable_set(k, convert_json_string_value(v))
          # end
        end
      end
    end
  end
end
