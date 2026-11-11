# frozen_string_literal: true

module Zm
  module Client
    module Base
      # objects returned by AdminObjectsCollection#all and find_in_batches
      class AdminObjectsResponse < Array
        def initialize(collection, items = [])
          super(items)
          @collection = collection
        end

        def update_all!(hash = nil, onerror: AdminObjectsCollection::ONERRORS.first, update_attributes: true, **attrs)
          @collection.mass_update!(self, hash, onerror:, update_attributes:, **attrs)
        end

        def delete_all!(onerror: AdminObjectsCollection::ONERRORS.first)
          @collection.mass_delete!(self, onerror:)
        end
      end
    end
  end
end
