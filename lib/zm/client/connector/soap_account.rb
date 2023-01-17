# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'
# require 'gyoku'

# include OpenSSL
# include Digest

module Zm
  module Client
    class SoapAccountConnector < SoapBaseConnector

      # SOAP_PATH = '/service/soap/'
      MAILSPACE = 'urn:zimbraMail'
      ACCOUNTSPACE = 'urn:zimbraAccount'
      A_NODE_PROC = lambda { |n| { n: n.first, _content: n.last } }
      # A_NODE_PROC_NAME = lambda { |n| { name: n.first, _content: n.last } }
      # A_NODE_PROC_ARROW_NAME = lambda { |n| { :@name => n.first, content!: n.last } }

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
        res[BODY][:AuthResponse][:authToken].first[:_content]
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

      def cancel_appointment(token, jsns)
        soap_name = :CancelAppointmentRequest
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(jsns)
        curl_request(body)
      end

      # -------------------------------
      # CONTACT

      def get_all_contacts(token, folder_id = nil)
        body = init_hash_request(token, :GetContactsRequest)
        unless folder_id.nil?
          req = { l: folder_id }
          body[:Body][:GetContactsRequest].merge!(req)
        end
        curl_request(body)
      end

      def create_contact(token, folder_id, attrs)
        a = attrs.to_a.map(&A_NODE_PROC)
        soap_name = :CreateContactRequest
        req = { cn: { a: a, l: folder_id } }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def modify_contact(token, id, attrs)
        a = attrs.to_a.map(&A_NODE_PROC)
        soap_name = :ModifyContactRequest
        req = { cn: { a: a, id: id } }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def create_group_contact(token, folder_id, attrs, members = [])
        soap_name = :CreateContactRequest
        a = attrs.to_a.map(&A_NODE_PROC)
        req = { cn: { a: a, l: folder_id, m: members } }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def modify_group_contact(token, id, attrs, members = [])
        soap_name = :ModifyContactRequest
        a = attrs.to_a.map(&A_NODE_PROC)
        req = { cn: { a: a, id: id, m: members } }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def contact_action(token, op, id, options = {})
        soap_name = :ContactActionRequest
        action = { op: op, id: id }.merge(options)
        req = { action: action }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
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

      def item_action(token, op, id, options = {})
        soap_name = :ItemActionRequest
        action = { op: op, id: id }.merge(options)
        req = { action: action }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # FOLDER

      def get_folder(token, jsns)
        jsns_request(:GetFolderRequest, token, jsns)
      end

      # def get_all_folders(token, view = nil, tr = nil)
      #   soap_name = :GetFolderRequest
      #   body = init_hash_request(token, soap_name)
      #   req = { view: view, tr: tr }.reject { |_, v| v.nil? }
      #   body[:Body][soap_name].merge!(req)
      #   curl_request(body)
      # end

      def create_folder(token, jsns)
        jsns_request(:CreateFolderRequest, token, jsns)
      end

      def folder_action(token, jsns)
        jsns_request(:FolderActionRequest, token, jsns)
      end

      def get_all_search_folders(token)
        soap_name = :GetSearchFolderRequest
        body = init_hash_request(token, soap_name)
        curl_request(body)
      end

      # -------------------------------
      # SEARCH FOLDER

      def create_search_folder(token, jsns)
        jsns_request(:CreateSearchFolderRequest, token, jsns)
      end

      def modify_search_folder(token, jsns)
        jsns_request(:ModifySearchFolderRequest, token, jsns)
      end

      # -------------------------------
      # TASK

      def create_task(token, folder_id, name, description = nil, options = {})
        comp = { name: name }
        comp.merge!(options) if !options.nil? && !options.empty?

        task = { su: name, l: folder_id, inv: { comp: [comp] } }

        task[:mp] = { ct: 'text/plain', content: description } unless description.nil?

        req = { m: task }

        body = init_hash_request(token, :CreateTaskRequest)
        body[:Body][:CreateTaskRequest].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # SHARE

      def create_mountpoint(token, jsns)
        jsns_request(:CreateMountpointRequest, token, jsns)
      end

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
      # TAG

      def get_tag(token)
        body = init_hash_request(token, :GetTagRequest)
        curl_request(body)
      end

      def create_tag(token, jsns)
        jsns_request(:CreateTagRequest, token, jsns)
      end

      def tag_action(token, jsns)
        jsns_request(:TagActionRequest, token, jsns)
      end

      # -------------------------------
      # IDENTITY

      def get_all_identities(token)
        body = init_hash_request(token, :GetIdentitiesRequest, ACCOUNTSPACE)
        curl_request(body)
      end

      def create_identity(token, name, attrs = [])
        soap_name = :CreateIdentityRequest
        req = {
          identity: {
            id: id,
            _attrs: attrs
          }
        }

        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def modify_identity(token, id, attrs = [])
        soap_name = :ModifyIdentityRequest
        req = {
          identity: {
            id: id,
            _attrs: attrs
          }
        }

        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def delete_identity(token, id)
        soap_name = :DeleteIdentityRequest
        req = { identity: { id: id } }
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
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
        puts body
        curl_request(body)
      end

      def get_filter_rules(token)
        soap_name = :GetFilterRulesRequest
        body = init_hash_request(token, soap_name)
        curl_request(body)
      end

      def modify_filter_rules(token, rules)
        soap_name = :ModifyFilterRulesRequest
        req = { filterRules: [{ filterRule: rules }] }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_signatures(token)
        soap_name = :GetSignaturesRequest
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        curl_request(body)
      end

      def create_signature(token, jsns)
        soap_name = :CreateSignatureRequest
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(jsns)
        curl_request(body)
      end

      def modify_signature(token, jsns)
        soap_name = :ModifySignatureRequest
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(jsns)
        curl_request(body)
      end

      def delete_signature(token, jsns)
        soap_name = :DeleteSignatureRequest
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(jsns)
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

      # def init_hash_arrow_request(token, soap_name, namespace = MAILSPACE)
      #   { Envelope: {
      #       :@xmlns => 'http://schemas.xmlsoap.org/soap/envelope/',
      #       '@xmlns:urn' => 'urn:zimbra',
      #       Header: {
      #         context: {
      #           authToken: token,
      #           :@xmlns => BASESPACE,
      #           format: {
      #               :@type => 'js'
      #           }
      #         }
      #       },
      #       Body: {
      #         soap_name => { :@xmlns => namespace }
      #       }
      #     }
      #   }
      # end
    end
  end
end
