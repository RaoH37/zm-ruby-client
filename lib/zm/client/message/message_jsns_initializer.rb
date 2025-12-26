# frozen_string_literal: true

module Zm
  module Client
    # class for initialize account message
    class MessageJsnsInitializer
      class << self
        def create(parent, json)
          Message.new(parent).tap do |item|
            update(item, json)
          end
        end

        def update(item, json)
          item.id = json.delete(:id)
          item.d = json.delete(:d)
          item.l    = json.delete(:l)
          item.su   = json.delete(:su)
          item.fr   = json.delete(:fr)
          item.autoSendTime = json.delete(:autoSendTime)
          item.mid  = json.delete(:mid)
          item.idnt = json.delete(:idnt)
          item.f = json.delete(:f)
          item.tn = json.delete(:tn)
          item.s = json.delete(:s)

          json[:e].each do |e|
            recipient = Recipient.new(e.delete(:t), e.delete(:a), e.delete(:p))
            item.recipients.add(recipient)
          end

          update_mps(item, json.delete(:mp))

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
          pj.mid  = json.delete(:mid)
          pj.aid  = json.delete(:aid)
          pj.ct   = json.delete(:ct)
          pj.s    = json.delete(:s)
          pj.filename = json.delete(:filename)
          pj.ci   = json.delete(:ci)
          pj.cd   = json.delete(:cd)
          pj.part = json.delete(:part)
          item.attachments.add(pj)
        end
      end
    end
  end
end
