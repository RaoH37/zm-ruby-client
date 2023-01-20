# frozen_string_literal: true

module Zm
  module Client
    # class for initialize domain
    class DomainJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Domain.new(parent)

          update(item, json)
        end

          def update(item, json)
            item = super(item, json)

            item.zimbraGalAccountId = [item.zimbraGalAccountId] if item.zimbraGalAccountId.is_a?(String)
            item.zimbraGalLdapAttrMap = [item.zimbraGalLdapAttrMap] if item.zimbraGalLdapAttrMap.is_a?(String)

            item
          end
      end
    end
  end
end
