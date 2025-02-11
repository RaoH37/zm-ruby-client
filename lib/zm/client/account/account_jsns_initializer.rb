# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class AccountJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Account.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]
          item.used = json[:used] unless json[:used].nil?
          item.zimbraMailQuota = json[:limit] unless json[:limit].nil?

          fjson = formatted_json(json)
          fjson.transform_keys! { |k| :"#{k}=" }

          # formatted_json(json).each do |k, v|
          fjson.each do |k, v|
            # valorise(item, k, v)
            setter = :"#{k}="
            item.send(setter, v) if item.respond_to? setter
          end

          item
        end
      end
    end
  end
end
