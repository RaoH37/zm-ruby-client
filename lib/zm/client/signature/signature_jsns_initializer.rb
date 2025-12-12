# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account signature
    class SignatureJsnsInitializer
      class << self
        def create(parent, json)
          Signature.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.name = json.delete(:name)

          content = json[:content].is_a?(Array) ? json[:content] : [json[:content]]

          content.compact!

          content.each do |c|
            next if c[:type].nil?

            item.txt = c[:_content] if c[:type] == ContentType::TEXT
            item.html = c[:_content] if c[:type] == ContentType::HTML
          end

          item
        end
      end
    end
  end
end
