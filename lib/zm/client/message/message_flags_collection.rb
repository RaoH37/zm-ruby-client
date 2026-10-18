# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class MessageFlagsCollection
      def initialize(parent)
        @parent = parent
      end

      def all
        @all ||= @parent.f.to_s.chars
      end

      # properties

      def unread?
        all.include?('u')
      end

      def flagged?
        all.include?('f')
      end

      def attachment?
        all.include?('a')
      end

      def replied
        all.include?('r')
      end

      def sent_by_me?
        all.include?('s')
      end

      def forwarded?
        all.include?('w')
      end

      def calendar_invite?
        all.include?('v')
      end

      def draft?
        all.include?('d')
      end

      def imap_deleted?
        all.include?('x')
      end

      def notification?
        all.include?('n')
      end

      def urgent?
        all.include?('!')
      end

      def low_priority?
        all.include?('?')
      end

      def priority?
        all.include?('+')
      end

      # actions

      def unread!
        apply(build_unread, 'u', true)
      end

      def build_unread
        build({ op: '!read', id: @parent.id })
      end

      def read!
        apply(build_read, 'u', false)
      end

      def build_read
        build({ op: 'read', id: @parent.id })
      end

      def unflag!
        apply(build_unflag, 'f', false)
      end

      def build_unflag
        build({ op: '!flag', id: @parent.id })
      end

      def flag!
        apply(build_flag, 'f', true)
      end

      def build_flag
        build({ op: 'flag', id: @parent.id })
      end

      private

      def soap_connector
        @parent.parent.soap_connector
      end

      def apply(soap_request, flag, enabled)
        response = soap_connector.invoke(soap_request)

        if enabled
          all << flag unless all.include?(flag)
        else
          all.delete(flag)
        end
        @parent.f = all.join

        response
      end

      def build(attrs)
        soap_request = SoapRequest::SoapElement.mail(SoapRequest::SoapMailConstants::ITEM_ACTION_REQUEST)
        node_action = SoapRequest::SoapElement.create(SoapRequest::SoapConstants::ACTION).add_attributes(attrs)
        soap_request.add_node(node_action)
        soap_request
      end
    end
  end
end
