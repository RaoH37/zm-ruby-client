# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account data source
    class DataSourceJsnsInitializer
      class << self
        def create(parent, data_source_type, json)
          item = DataSource.new(parent, data_source_type)
          update(item, json)
        end

        def update(item, json)
          json.each do |k, v|
            setter_method = "#{k}=".to_sym

            if item.respond_to?(setter_method)
              item.send(setter_method, v)
            end
          end

          item
        end
      end
    end
  end
end
