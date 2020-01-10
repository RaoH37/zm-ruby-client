# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::AccountObject
      TYPE_TXT = 'text/plain'
      TYPE_HTML = 'text/html'

      attr_accessor :id, :name, :txt, :html

      def init_from_json(json)
        @id      = json[:id]
        @name    = json[:name]
        json[:content].each do |c|
          @txt = c[:_content] if c[:type] == TYPE_TXT
          @html = c[:_content] if c[:type] == TYPE_HTML
        end if json[:content].is_a?(Array)
      end

      def create!
        # todo
      end

      def delete!
        # todo
      end
    end
  end
end
