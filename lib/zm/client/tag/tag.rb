# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::Object
      include RequestMethodsMailbox

      extend Philosophal::Properties

      cprop :id, Integer
      cprop :name, String
      cprop :color, Integer
      cprop :rgb, String

      def create!
        rep = @parent.sacc.invoke(build_create)
        json = rep[:CreateTagResponse][:tag].first
        TagJsnsInitializer.update(self, json)
        @id
      end

      private

      def jsns_builder
        @jsns_builder ||= TagJsnsBuilder.new(self)
      end
    end
  end
end
