# frozen_string_literal: true

module Zm
  module Client
    # class message for account
    class Message < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[id date l su fr autoSendTime mid idnt]
      attr_accessor *INSTANCE_VARIABLE_KEYS

      attr_accessor :subject
      attr_reader :recipients, :attachments, :body, :folder

      def initialize(parent, json = nil)
        @parent = parent
        @recipients = Recipients.new
        @subject = ''
        @body = Body.new
        @attachments = Attachments.new

        init_from_json(json) if json.is_a?(Hash)

        yield(self) if block_given?
      end

      def has_attachment?
        @has_attachment ||= @attachments.all.any?
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def from
        @from ||= @recipients.find { |r| r.field == Recipient::FROM }
      end

      def folder=(folder)
        @folder = folder
        @l = folder.id
      end

      def delete!
        msg_action('delete')
      end

      def move!(folder_id = l)
        msg_action('move', l: folder_id)
        l = folder_id if l != folder_id
      end

      def unread!
        msg_action('!read')
      end

      def read!
        msg_action('read')
      end

      def unflag!
        msg_action('!flag')
      end

      def flag!
        msg_action('flag')
      end

      def untag!(tag_name)
        msg_action('!tag', tn: tag_name)
      end

      def tag!(tag_name)
        msg_action('tag', tn: tag_name)
      end

      def unspam!
        msg_action('!spam')
      end

      def spam!
        msg_action('spam')
      end

      def trash!
        msg_action('trash')
      end

      def send!
        @parent.sacc.send_msg(@parent.token, to_jsns)
      end

      def to_jsns
        h = {
          id: @id,
          attach: @attachments.to_jsns,
          e: @recipients.to_jsns,
          su: { _content: @su },
          mp: @body.to_jsns
        }.delete_if { |_, v| v.nil? }

        h[:did] = @id if l.to_i == FolderDefault::DRAFTS[:id]

        h
      end

      def init_from_json(json)
        # puts json
        @id   = json[:id]
        @date = Time.at(json[:d]/1000)
        @l    = json[:l]
        @su   = json[:su]
        @fr   = json[:fr]
        @autoSendTime   = json[:autoSendTime]
        @mid  = json[:mid]
        @idnt = json[:idnt]
        @has_attachment = json[:f].to_s.include?('a')

        json[:e].each do |e|
          recipient = Recipient.new(e[:t], e[:a], e[:p])
          @recipients.add(recipient)
        end

        init_part_from_json(json[:mp])
      end

      def init_part_from_json(json)
        return if json.nil?
        # puts json
        json = [json] unless json.is_a?(Array)

        json.each do |json_part|
          if ['text/plain', 'text/html'].include?(json_part[:ct])
            init_body_from_json(json_part)
          elsif json_part[:cd] == 'attachment'
            init_attachment_from_json(json_part)
          else
            init_part_from_json(json_part[:mp])
          end
        end
      end

      def init_body_from_json(json)
        # puts "\ninit_body_from_json #{json}\n"
        body.text = json[:content] if json[:ct] == 'text/plain'
        body.html = json[:content] if json[:ct] == 'text/html'
      end

      def init_attachment_from_json(json)
        # puts "\ninit_attachment_from_json #{json}\n"
        pj = Zm::Client::Message::Attachment.new(self)
        # pj.part = json[:part],
        pj.mid  = json[:mid]
        pj.aid  = json[:aid]
        pj.ct   = json[:ct]
        pj.s    = json[:s]
        pj.filename = json[:filename]
        pj.ci   = json[:ci]
        pj.cd   = json[:cd]
        pj.part = json[:part]
        attachments.add(pj)
      end

      def msg_action(action_name, options = {})
        @parent.sacc.msg_action(@parent.token, action_name, id, options)
        true
      end

      # content fo an email
      class Body
        attr_accessor :text, :html

        def text_jsns
          @text.nil? ? nil : { ct: 'text/plain', content: { _content: @text } }
        end

        def html_jsns
          @html.nil? ? nil : { ct: 'text/html', content: { _content: @html } }
        end

        def to_jsns
          [
            {
              ct: 'multipart/alternative',
              mp: [text_jsns, html_jsns].compact
            }
          ]
        end
      end

      # collection attachments
      class Attachments
        attr_reader :all
        def initialize
          @all = []
        end

        def add(attachment)
          return unless attachment.is_a?(Attachment)

          @all.push(attachment)
        end

        def to_jsns
          @all.map(&:to_jsns)
        end
      end

      # class attachment for email
      class Attachment
        attr_accessor :aid, :part, :mid, :ct, :s, :filename, :ci, :cd

        def initialize(parent)
          @parent = parent
          yield(self) if block_given?
        end

        def download(dest_file_path)
          h = {
            id: @parent.id,
            part: part,
            auth: 'qp',
            zauthtoken: account.token,
            disp: 'a'
          }

          url = account.home_url

          uri = Addressable::URI.new
          uri.query_values = h
          url << '?' << uri.query

          uploader = Upload.new(@parent, RestAccountConnector.new)
          uploader.download_file_with_url(url, dest_file_path)
        end

        def to_jsns
          {
            part: part,
            mid: mid,
            aid: aid,
            ct: ct,
            s: s,
            filename: filename,
            ci: ci,
            cd: cd
          }.reject { |_, v| v.nil? }
        end

        def account
          @parent.parent
        end
      end

      # Collection recipients
      class Recipients
        def initialize
          @recipients = []
        end

        def to_jsns
          @recipients.map(&:to_jsns)
        end

        def add(recipient)
          return unless recipient.is_a?(Recipient)

          @recipients.push(recipient)
        end

        def to
          @recipients.select { |r| r.field == Recipient::TO }
        end

        def cc
          @recipients.select { |r| r.field == Recipient::CC }
        end

        def bcc
          @recipients.select { |r| r.field == Recipient::BCC }
        end

        def from
          @recipients.select { |r| r.field == Recipient::FROM }
        end
      end

      # Class one recipient for email
      class Recipient
        FROM = :f
        TO = :t
        CC = :c
        BCC = :b

        attr_accessor :field, :email, :display_name

        def initialize(field, email, display_name = nil)
          @email = email
          @field = field.to_sym
          @display_name = display_name
        end

        def to_s
          "#{@email} (#{@display_name})"
        end

        def to_jsns
          {
            t: @field,
            a: @email,
            p: @display_name
          }.reject { |_, v| v.nil? }
        end
      end
    end
  end
end
