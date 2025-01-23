# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message
      class FlagsCollection
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
          @parent.sacc.invoke(build_unread)
        end

        def build_unread
          build({ op: '!read', id: @parent.id })
        end

        def read!
          @parent.sacc.invoke(build_read)
        end

        def build_read
          build({ op: 'read', id: @parent.id })
        end

        def unflag!
          @parent.sacc.invoke(build_unflag)
        end

        def build_unflag
          build({ op: '!flag', id: @parent.id })
        end

        def flag!
          @parent.sacc.invoke(build_flag)
        end

        def build_flag
          build({ op: 'flag', id: @parent.id })
        end

        private

        def build(attrs)
          soap_request = SoapElement.mail(SoapMailConstants::ITEM_ACTION_REQUEST)
          node_action = SoapElement.create(SoapConstants::ACTION).add_attributes(attrs)
          soap_request.add_node(node_action)
          soap_request
        end
      end
    end
  end
end
