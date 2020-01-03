# frozen_string_literal: true

module Zm
  module Client
    # class account ace
    class Ace < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[zid gt right d]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def init_from_json(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          var_name = "@#{key}"
          instance_variable_set(var_name, json[key])
        end
      end

      def create!
        # todo
      end

      def delete!
        # todo
      end

      def rename!(new_name)
        # todo
      end
    end
  end
end
