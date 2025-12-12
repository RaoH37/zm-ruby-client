# frozen_string_literal: true

module Zm
  module Client
    # class for initialize resource
    class ResourceJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          Resource.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.name = json.delete(:name)
          item.used = json.delete(:used) unless json[:used].nil?
          item.zimbraMailQuota = json.delete(:limit) unless json[:limit].nil?

          formatted_json(json).each do |k, v|
            valorise(item, k, v)
          end

          item
        end
      end
    end
  end
end
