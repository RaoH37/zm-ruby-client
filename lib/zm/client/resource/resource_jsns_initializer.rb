# frozen_string_literal: true

module Zm
  module Client
    # class for initialize resource
    class ResourceJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def klass = Resource

        def update(item, json)
          item.used = json.delete(:used) unless json[:used].nil?
          item.zimbraMailQuota = json.delete(:limit) unless json[:limit].nil?

          super
        end
      end
    end
  end
end
