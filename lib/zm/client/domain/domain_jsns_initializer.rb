# frozen_string_literal: true

module Zm
  module Client
    # class for initialize domain
    class DomainJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def klass = Domain

        def update(item, json)
          item = super

          wrap_string(item, :@zimbraGalAccountId)
          wrap_string(item, :@zimbraGalLdapAttrMap)

          item
        end

        private

        def wrap_string(item, ivar)
          value = item.instance_variable_get(ivar)
          item.instance_variable_set(ivar, [value]) if value.is_a?(String)
        end
      end
    end
  end
end
