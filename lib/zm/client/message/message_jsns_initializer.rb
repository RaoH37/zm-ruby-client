# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account message
    class MessageJsnsInitializer
      class << self
        def create(parent, json)
          item = Message.new(parent)
          update(item, json)
        end

        def update(item, json)
          item.id = json[:id]
          item.d = json[:d]
          item.l    = json[:l]
          item.su   = json[:su]
          item.fr   = json[:fr]
          item.autoSendTime = json[:autoSendTime]
          item.mid  = json[:mid]
          item.idnt = json[:idnt]
          item.f = json[:f]
          item.tn = json[:tn]
          item.s = json[:s]

          json[:e].each do |e|
            recipient = Recipient.new(e[:t], e[:a], e[:p])
            item.recipients.add(recipient)
          end

          update_mps(item, json[:mp])

          item
        end

        def update_mps(item, mps)
          return if mps.nil?

          mps = [mps] unless mps.is_a?(Array)

          mps.each do |mp|
            if ContentType::ALL.include?(mp[:ct])
              update_body(item, mp)
            elsif mp[:cd] == 'attachment'
              update_attachment(item, mp)
            else
              update_mps(item, mp[:mp])
            end
          end
        end

        def update_body(item, json)
          item.body.text = json[:content] if json[:ct] == ContentType::TEXT
          item.body.html = json[:content] if json[:ct] == ContentType::HTML
        end

        def update_attachment(item, json)
          pj = Zm::Client::Message::Attachment.new(self)
          pj.mid  = json[:mid]
          pj.aid  = json[:aid]
          pj.ct   = json[:ct]
          pj.s    = json[:s]
          pj.filename = json[:filename]
          pj.ci   = json[:ci]
          pj.cd   = json[:cd]
          pj.part = json[:part]
          item.attachments.add(pj)
        end
      end
    end
  end
end
