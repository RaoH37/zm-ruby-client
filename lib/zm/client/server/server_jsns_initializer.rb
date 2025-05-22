# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account
    class ServerJsnsInitializer < Base::BaseJsnsInitializer
      class << self
        def create(parent, json)
          item = Server.new(parent)

          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]

          fjson = formatted_json(json)
          fjson.transform_keys! { |k| :"#{k}=" }

          fjson.each do |setter, v|
            item.send(setter, v) if item.respond_to? setter
          end

          item
        end
      end
    end
  end
end
