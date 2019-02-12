module Zm
  module Client
    module Base
      # Abstract Class Provisionning Object
      class Object
        # ATTRS_READ = [].freeze
        # ATTRS_WRITE = [].freeze

        attr_accessor :token, :name, :id

        # attr_reader :soap_account_connector, :rest_account_connector

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def soap_admin_connector
          @parent.soap_admin_connector
        end

        alias sac soap_admin_connector

        # def soap_admin_connector=(soap_admin_connector)
        #   @soap_admin_connector = soap_admin_connector
        # end

        # def soap_account_connector=(soap_account_connector)
        #   @soap_account_connector = soap_account_connector
        # end

        # def rest_account_connector=(rest_account_connector)
        #   @rest_account_connector = rest_account_connector
        # end

        def concat
          instance_variables
        end

        def to_s
          concat.join(' :: ')
        end

        def init_from_json(json)
          @id    = json[:id]
          @name  = json[:name]
          return unless json[:a].is_a? Array

          # fix car le tableau peut contenir des {} vide !
          json[:a].reject! { |n| n[:n].nil? }
          json_map = json[:a].map { |n| ["@#{n[:n]}", n[:_content]] }.freeze

          Hash[json_map].each do |k, v|
            instance_variable_set(k, convert_json_string_value(v))
          end
        end

        def convert_json_string_value(value)
          return value unless value.is_a?(String)
          return 0 if value == '0'

          c = value.to_i
          c.to_s == value ? c : value
        end

        def recorded?
          !@id.nil?
        end

        def save!
          recorded? ? modify! : create!
        end

        def instance_variables_array(zcs_attrs)
          selected_attrs = zcs_attrs.map { |a| a.to_s.insert(0, '@').to_sym }
          Hash[(instance_variables & selected_attrs).map do |name|
            [name.to_s[1..-1], instance_variable_get(name)]
          end]
        end
      end
    end
  end
end
