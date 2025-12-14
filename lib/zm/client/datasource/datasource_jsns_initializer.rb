# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account data source
    class DataSourceJsnsInitializer
      class << self
        def create(parent, data_source_type, json)
          DataSource.new(parent, data_source_type).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          json.each do |k, v|
            setter_method = :"#{k}="

            item.send(setter_method, v) if item.respond_to?(setter_method)
          end

          item
        end
      end
    end
  end
end
