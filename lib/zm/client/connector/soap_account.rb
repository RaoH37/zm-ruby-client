# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'

module Zm
  module Client
    class SoapAccountConnector < SoapBaseConnector
      # SOAP_PATH = '/service/soap/'
      MAILSPACE = 'urn:zimbraMail'
      ACCOUNTSPACE = 'urn:zimbraAccount'
      A_NODE_PROC = ->(n) { { n: n.first, _content: n.last } }

      def initialize(scheme, host, port)
        super(scheme, host, port, '/service/soap/')
      end

      def auth_template(mail)
        {
          Body: {
            AuthRequest: {
              _jsns: ACCOUNTSPACE,
              account: {
                _content: mail,
                by: :name
              }
            }
          }
        }
      end

      def auth_preauth(mail, domainkey)
        ts = (Time.now.to_i * 1000)
        preauth = compute_preauth(mail, ts, domainkey)
        body = auth_template(mail)
        preauth_h = {
          preauth: {
            _content: preauth,
            timestamp: ts
          }
        }
        body[:Body][:AuthRequest].merge!(preauth_h)
        do_auth(body)
      end

      def auth_password(mail, password)
        body = auth_template(mail)
        body[:Body][:AuthRequest].merge!({ password: password })
        do_auth(body)
      end

      def do_auth(body)
        res = curl_request(body, AuthError)
        res[:Body][:AuthResponse][:authToken].first[:_content]
      end

      # -------------------------------
      # APPOINTMENT

      def get_appointment(token, id)
        req = { id: id }
        body = init_hash_request(token, :GetAppointmentRequest)
        body[:Body][:GetAppointmentRequest].merge!(req)
        curl_request(body)
      end

      def create_appointment(token, jsns)
        soap_name = :CreateAppointmentRequest
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(jsns)
        curl_request(body)
      end

      def modify_appointment(token, jsns)
        soap_name = :ModifyAppointmentRequest
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(jsns)
        curl_request(body)
      end

      # -------------------------------
      # DOCUMENT

      def save_document(token, l, options = {})
        soap_name = :SaveDocumentRequest
        body = init_hash_request(token, soap_name)
        req = { doc: { l: l } }
        req[:doc].merge!(options)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # SHARE

      def get_share_info(token, options = {})
        soap_name = :GetShareInfoRequest
        req = { includeSelf: 0 }.merge!(options)
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_rights(token, jsns)
        jsns_request(:GetRightsRequest, token, jsns, ACCOUNTSPACE)
      end

      def grant_rights(token, jsns)
        jsns_request(:GrantRightsRequest, token, jsns, ACCOUNTSPACE)
      end

      def revoke_rights(token, jsns)
        jsns_request(:RevokeRightsRequest, token, jsns, ACCOUNTSPACE)
      end

      # -------------------------------
      # MESSAGE

      def get_msg(token, id, options = {})
        req = { m: { id: id } }
        req[:m].merge!(options) unless options.empty?
        body = init_hash_request(token, :GetMsgRequest)
        body[:Body][:GetMsgRequest].merge!(req)
        curl_request(body)
      end

      def msg_action(token, op, id, options = {})
        action = { op: op, id: id }.merge(options)
        req = { action: action }
        body = init_hash_request(token, :MsgActionRequest)
        body[:Body][:MsgActionRequest].merge!(req)
        curl_request(body)
      end

      def send_msg(token, m)
        req = { m: m }
        body = init_hash_request(token, :SendMsgRequest)
        body[:Body][:SendMsgRequest].merge!(req)
        # curl_request(body)
      end

      def add_msg(token, l, eml, d = nil, f = nil, tn = nil)
        key = :AddMsgRequest
        m = {
          l: l,
          d: d,
          f: f,
          tn: tn,
          content: { _content: eml }
        }.reject { |_, v| v.nil? }

        req = { m: m }
        body = init_hash_request(token, key)
        body[:Body][key].merge!(req)

        curl_request(body)
      end

      # -------------------------------
      # PREFERENCES

      def get_prefs(token, *names)
        req = { prefs: names.map { |name| { name: name } } }
        body = init_hash_request(token, :GetPrefsRequest, ACCOUNTSPACE)
        body[:Body][:GetPrefsRequest].merge!(req) if req.any?
        curl_request(body)
      end

      def modify_prefs(token, prefs)
        soap_name = :ModifyPrefsRequest

        # The JSON version is different:
        # {
        #   ModifyPrefsRequest: {
        #     "_attrs": {
        #       "prefName1": "prefValue1",
        #       "prefName2": "prefValue2"
        #       "+nameOfMulitValuedPref3": "addedPrefValue3",
        #       "-nameOfMulitValuedPref4": "removedPrefValue4",
        #       "nameOfMulitValuedPref5": ["prefValue5one","prefValue5two"],
        #       ...
        #     },
        #     _jsns: "urn:zimbraAccount"
        #   }
        # }

        req = {
          _attrs: prefs
        }

        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req) if req.any?
        # puts body
        curl_request(body)
      end

      def get_filter_rules(token)
        jsns_request(:GetFilterRulesRequest, token, nil)
      end

      def modify_filter_rules(token, rules)
        soap_name = :ModifyFilterRulesRequest
        req = { filterRules: [{ filterRule: rules }] }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # GENERIC

      def get_info(token, sections = 'mbox,prefs,attrs,zimlets,props,idents,sigs,dsrcs,children', rights = nil)
        req = { rights: rights, sections: sections }.reject { |_, v| v.nil? }
        body = init_hash_request(token, :GetInfoRequest, ACCOUNTSPACE)
        body[:Body][:GetInfoRequest].merge!(req) if req.any?
        curl_request(body)
      end

      def search(token, types = nil, offset = nil, limit = nil, sortBy = nil, query = nil, options = {})
        soap_name = :SearchRequest
        # types: conversation|message|contact|appointment|task|wiki|document
        req = {
          types: types,
          offset: offset,
          limit: limit,
          sortBy: sortBy,
          query: query,
          header: [{ n: 'messageIdHeader' }]
        }.merge!(options)
        req.reject! { |_, v| v.nil? }

        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req) if req.any?
        curl_request(body)
      end

      def jsns_request(soap_name, token, jsns, namespace = MAILSPACE)
        body = init_hash_request(token, soap_name, namespace)
        body[:Body][soap_name].merge!(jsns) if jsns.is_a?(Hash)
        curl_request(body)
      end

      def ranking_action(token, op, email = nil)
        soap_name = :RankingActionRequest
        req = {
          action: {
            op: op,
            email: email
          }
        }
        req[:action].delete_if { |_, v| v.nil? }

        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req) if req.any?

        curl_request(body)
      end

      private

      def compute_preauth(mail, ts, domainkey)
        data = "#{mail}|name|0|#{ts}"
        digest = OpenSSL::Digest.new('sha1')
        hmac = OpenSSL::HMAC.hexdigest(digest, domainkey, data)
        hmac.to_s
      end

      def init_hash_request(token, soap_name, namespace = MAILSPACE)
        {
          Body: {
            soap_name => { _jsns: namespace }
          }
        }.merge(hash_header(token))
      end
    end
  end
end
