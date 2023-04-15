# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account signature
    class SignatureJsnsInitializer
      class << self
        def create(parent, json)
          item = Signature.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.name = json[:name]

          content = json[:content].is_a?(Array) ? json[:content] : [json[:content]]

          content.each do |c|
            item.txt = c[:_content] if c[:type] == ContentType::TEXT
            item.html = c[:_content] if c[:type] == ContentType::HTML
          end

          item
        end
      end
    end
  end
end
