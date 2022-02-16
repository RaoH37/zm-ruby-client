# frozen_string_literal: true

module Zm
  module Client
    module Base
      # class for account object jsns initializer
      class BaseJsnsInitializer

        def initialize(parent, json)
          @parent = parent
          @json = json
        end

        def create
          @item ||= @child_class.new(@parent)

          @item.instance_variable_set(:@id, @json[:id])
          @item.instance_variable_set(:@name, @json[:name])
        end

        def arrow_name(name)
          return name if name.to_s.start_with?('@')

          "@#{name}"
        end
      end
    end
  end
end
