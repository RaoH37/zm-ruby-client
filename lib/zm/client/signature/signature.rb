# frozen_string_literal: true

module Zm
  module Client
    # class account signature
    class Signature < Base::AccountObject
      TYPE_TXT = 'text/plain'
      TYPE_HTML = 'text/html'

      INSTANCE_VARIABLE_KEYS = %i[id name txt html]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def init_from_json(json)
        @id      = json[:id]
        @name    = json[:name]
        json[:content].each do |c|
          @txt = c[:_content] if c[:type] == TYPE_TXT
          @html = c[:_content] if c[:type] == TYPE_HTML
        end if json[:content].is_a?(Array)
      end

      def create!
        rep = @parent.sacc.create_signature(@parent.token, name, type, content)
        @id = rep[:Body][:CreateSignatureResponse][:signature].first[:id]
      end

      def modify!
        @parent.sacc.modify_signature(@parent.token, id, name, type, content)
      end

      def delete!
        @parent.sacc.delete_signature(@parent.token, id)
      end

      def type
        return TYPE_HTML unless html.nil?
        TYPE_TXT
      end

      def html?
        type == TYPE_HTML
      end

      def txt?
        type == TYPE_TXT
      end

      def content
        html || txt
      end
    end
  end
end
