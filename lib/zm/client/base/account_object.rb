# frozen_string_literal: true

module Zm
  module Client
    module Base
      # Abstract Class Provisionning AccountObject
      class AccountObject < Object
        def soap_account_connector
          @parent.soap_account_connector
        end

        alias sacc soap_account_connector

        def concat
          all_instance_variable_keys.map { |key| instance_variable_get(arrow_name(key)) }
        end

        def init_from_json(json)
          all_instance_variable_keys.each do |key|
            next if json[key].nil?

            instance_variable_set(arrow_name(key), json[key])
          end
        end

        def to_h
          hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
          hashmap.delete_if { |_, v| v.nil? }
          hashmap
        end

        def create!
          @id
        end

        def modify!
          rename!
          true
        end

        def rename!
          true
        end

        def delete!
          remove_instance_variable(:@id)
        end
      end
    end
  end
end
