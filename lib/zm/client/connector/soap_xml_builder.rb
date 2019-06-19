# frozen_string_literal: true

require 'nokogiri'
# https://stackoverflow.com/questions/11933451/converting-nested-hash-into-xml-using-nokogiri

class SoapXmlBuilder
  ATTRS_NODE_PROC = ->(k, _) { k.to_s.start_with?('_') }

  def initialize(hash)
    @hash = hash
  end

  def to_xml
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.Envelope('xmlns' => 'http://schemas.xmlsoap.org/soap/envelope/', 'xmlns:urn' => 'urn:zimbra') do
        header(xml)
        body(xml)
      end
    end
    builder.to_xml
  end

  private

  def header(xml)
    return unless @hash[:Header]

    xml.Header do
      xml.context_('xmlns' => 'urn:zimbra') do
        xml.authToken @hash[:Header][:context][:authToken]
        xml.format('type' => 'js')
      end
    end
  end

  def body(xml)
    return unless @hash[:Body]

    xml.Body do
      generate_xml(@hash[:Body], xml)
    end
  end

  def generate_xml(hash, xml)
    hash.each do |req_name, req_h|
      xml.send(req_name, transform_keys(req_h.select(&ATTRS_NODE_PROC))) do
        req_h.reject(&ATTRS_NODE_PROC).each do |label, value|
          if value.is_a?(Hash)
            generate_xml(value, xml)
          elsif value.is_a?(Array)
            value.each do |el|
              xml.send(label, el.reject(&ATTRS_NODE_PROC), el[:_content])
            end
          else
            xml.send(label, value)
          end
        end
      end
    end
  end

  def transform_keys(hash)
    Hash[hash.map { |k, v| [k.to_s.sub(/\A_/, '').sub('jsns', 'xmlns'), v] }]
  end
end
