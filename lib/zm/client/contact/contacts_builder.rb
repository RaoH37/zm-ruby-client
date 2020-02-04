# frozen_string_literal: true

module Zm
  module Client
    # class factory [contacts]
    class ContactBuilder < Base::ObjectsBuilder

      def initialize(parent, json)
        @parent = parent
        @json = json
      end

      def make
        root = @json[:Body][:GetContactsResponse][:cn]
        return [] if root.nil?

        root = [root] unless root.is_a?(Array)
        root.map do |s|
          Contact.new(@parent, s)
        end
      end
    end
  end
end
