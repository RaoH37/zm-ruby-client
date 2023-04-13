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
          @all || all!
        end

        def all!
          @parent.f.to_s.chars
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
          @parent.parent.sacc.jsns_request(:ItemActionRequest, @parent.parent.token, { action: { op: '!read', id: @parent.id } })
        end

        def read!
          @parent.parent.sacc.jsns_request(:ItemActionRequest, @parent.parent.token, { action: { op: 'read', id: @parent.id } })
        end

        def unflag!
          @parent.parent.sacc.jsns_request(:ItemActionRequest, @parent.parent.token, { action: { op: '!flag', id: @parent.id } })
        end

        def flag!
          @parent.parent.sacc.jsns_request(:ItemActionRequest, @parent.parent.token, { action: { op: 'flag', id: @parent.id } })
        end
      end
    end
  end
end
