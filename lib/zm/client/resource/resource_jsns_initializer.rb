# frozen_string_literal: true

module Zm
  module Client
    # class for initialize resource
    class ResourceJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Resource.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]
          item.used = json[:used] unless json[:used].nil?
          item.zimbraMailQuota = json[:limit] unless json[:limit].nil?

          formatted_json(json).each do |k, v|
            valorise(item, k, v)
          end

          item
        end
      end
    end
  end
end
