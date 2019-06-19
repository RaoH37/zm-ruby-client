# frozen_string_literal: true

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

        def init_from_json(json)
          # TODO : know in advance the typing of variables
          super(json)
          return unless json[:a].is_a? Array

          # fix car le tableau peut contenir des {} vide !
          json[:a].reject! { |n| n[:n].nil? }
          json_map = json[:a].map { |n| ["@#{n[:n]}", n[:_content]] }.freeze

          json_hash = json_map.reduce({}) { |h, (k, v)| (h[k] ||= []); h[k].push(v); h }.inject({}) { |h, (k, v)| v.length == 1 ? h[k] = v.first : h[k] = v; h }

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
