# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Tag < Base::Object
      # include Zm::Model::AttributeChangeObserver
      include RequestMethodsMailbox

      attr_accessor :id, :name, :color, :rgb

      # define_changed_attributes :name, :color, :rgb

      def create!
        rep = @parent.soap_connector.invoke(build_create)
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
