# frozen_string_literal: true

require_relative 'soap_base'
require_relative 'soap_error'
require 'gyoku'

# include OpenSSL
# include Digest

module Zm
  module Client
    class SoapAccountConnector < SoapBaseConnector

      MAILSPACE = 'urn:zimbraMail'
      ACCOUNTSPACE = 'urn:zimbraAccount'
      A_NODE_PROC = lambda { |n| { n: n.first, _content: n.last } }
      A_NODE_PROC_NAME = lambda { |n| { name: n.first, _content: n.last } }
      A_NODE_PROC_ARROW_NAME = lambda { |n| { :@name => n.first, content!: n.last } }

      def initialize(scheme, host, port)
        @uri = URI::HTTP.new(scheme, nil, host, port, nil, '/service/soap/', nil, nil, nil)
        init_curl_client
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
        # puts body
        curl_request(body)
      end

      def modify_group_contact(token, id, attrs, members = [])
        soap_name = :ModifyContactRequest
        a = attrs.to_a.map(&A_NODE_PROC)
        req = { cn: { a: a, id: id, m: members } }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        # puts body
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
        # puts body
        curl_request(body)
      end

      # -------------------------------
      # FOLDER

      def get_folder(token, id)
        soap_name = :GetFolderRequest
        body = init_hash_request(token, soap_name)
        req = { folder: { l: id } }
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_all_folders(token, view = nil, tr = nil)
        soap_name = :GetFolderRequest
        body = init_hash_request(token, soap_name)
        req = { view: view, tr: tr }.reject { |_, v| v.nil? }
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def create_folder(token, folder_options)
        soap_name = :CreateFolderRequest
        # folder = { l: parent_id, name: name, view: view, color: color }.merge(options)
        req = { folder: folder_options }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def folder_action(token, op, id, options = {})
        soap_name = :FolderActionRequest
        action = { op: op, id: id }.merge(options)
        req = { action: action }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        # puts body
        curl_request(body)
      end

      def get_all_search_folders(token)
        body = init_hash_request(token, :GetSearchFolderRequest)
        curl_request(body)
      end

      # -------------------------------
      # SEARCH FOLDER

      def create_search_folder(token, name, query, types = 'messages', l = 1, color = nil, sort_by = nil)
        search = {
            name: name,
            query: query,
            types: types,
            sortBy: sort_by,
            color: color,
            l: l
        }.reject { |_, v| v.nil? }

        req = { search: search }
        body = init_hash_request(token, :CreateSearchFolderRequest)
        body[:Body][:CreateSearchFolderRequest].merge!(req)
        # puts body
        curl_request(body)
      end

      def modify_search_folder(token, id, query, types = 'messages')
        search = {
          id: id,
          query: query,
          types: types
        }.reject { |_, v| v.nil? }

        req = { search: search }
        body = init_hash_request(token, :ModifySearchFolderRequest)
        body[:Body][:ModifySearchFolderRequest].merge!(req)
        curl_request(body)
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

      def create_mountpoint(token, link_option)
        soap_name = :CreateMountpointRequest
        req = { link: link_option }
        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_share_info(token, options = {})
        soap_name = :GetShareInfoRequest
        req = { includeSelf: 0 }.merge!(options)
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def get_rights(token, rights)
        soap_name = :GetRightsRequest
        ace = rights.map { |r| { right: r } }
        req = { ace: ace }
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def grant_rights(token, zid = nil, gt = nil, right = nil, d = nil, key = nil, pw = nil, deny = nil, chkgt = nil)
        ace = {
          zid: zid,
          gt: gt,
          right: right,
          d: d,
          key: key,
          pw: pw,
          deny: deny,
          chkgt: chkgt
        }.reject { |_, v| v.nil? }

        req = { ace: ace }
        body = init_hash_request(token, :GrantRightsRequest, ACCOUNTSPACE)
        body[:Body][:GrantRightsRequest].merge!(req)
        curl_request(body)
      end

      def revoke_rights(token, zid = nil, gt = nil, right = nil, d = nil, key = nil, pw = nil, deny = nil, chkgt = nil)
        ace = {
          zid: zid,
          gt: gt,
          right: right,
          d: d,
          key: key,
          pw: pw,
          deny: deny,
          chkgt: chkgt
        }.reject { |_, v| v.nil? }

        req = { ace: ace }
        body = init_hash_request(token, :RevokeRightsRequest, ACCOUNTSPACE)
        body[:Body][:RevokeRightsRequest].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # MESSAGE

      def get_msg(token, id)
        req = { m: { id: id } }
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
        curl_request(body)
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

      def create_tag(token, name, color, rgb)
        body = init_hash_request(token, :CreateTagRequest)
        req = { tag: { name: name, color: color, rgb: rgb }.reject { |_, v| v.nil? } }
        body[:Body][:CreateTagRequest].merge!(req)
        curl_request(body)
      end

      def tag_action(token, op, id, options = {})
        action = { op: op, id: id }.merge(options)
        req = { action: action }
        body = init_hash_request(token, :TagActionRequest)
        body[:Body][:TagActionRequest].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # IDENTITY

      def get_all_identities(token)
        body = init_hash_request(token, :GetIdentitiesRequest, ACCOUNTSPACE)
        curl_request(body)
      end

      # def create_identity(token, name, attrs = [])
      #   soap_name = :CreateIdentityRequest
      #   req = { identity: { name: name, a: attrs.to_a.map(&A_NODE_PROC__NAME) } }
      #   body = init_hash_request(token, soap_name, ACCOUNTSPACE)
      #   body[:Body][soap_name].merge!(req)
      #   puts body
      #   curl_request(body)
      # end

      # def modify_identity(token, id, attrs = [])
      #   soap_name = :ModifyIdentityRequest
      #   req = { identity: { id: id, a: attrs.to_a.map(&A_NODE_PROC_NAME) } }
      #   body = init_hash_request(token, soap_name, ACCOUNTSPACE)
      #   body[:Body][soap_name].merge!(req)
      #   puts body
      #   curl_request(body)
      # end

      def create_identity(token, name, attrs = [])
        soap_name = :CreateIdentityRequest
        req = { identity: { :@name => name, a: attrs.to_a.map(&A_NODE_PROC_ARROW_NAME) } }
        body = init_hash_arrow_request(token, soap_name, ACCOUNTSPACE)
        body[:Envelope][:Body][soap_name].merge!(req)
        body_xml = Gyoku.xml(body, { :key_converter => :none })
        # puts body_xml
        # todo ne fonctionne pas en JS !
        curl_xml(body_xml)
      end

      def modify_identity(token, id, attrs = [])
        soap_name = :ModifyIdentityRequest
        req = { identity: { :@id => id, a: attrs.to_a.map(&A_NODE_PROC_ARROW_NAME) } }
        body = init_hash_arrow_request(token, soap_name, ACCOUNTSPACE)
        body[:Envelope][:Body][soap_name].merge!(req)
        body_xml = Gyoku.xml(body, { :key_converter => :none })
        # puts body_xml
        # todo ne fonctionne pas en JS !
        curl_xml(body_xml)
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
        req = { pref: prefs.map { |pref, value| { name: pref, _content: value } } }
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req) if req.any?
        #puts body
        #curl_request(body)
        #puts SoapXmlBuilder.new(body).to_xml
        # todo ne fonctionne pas en JS !
        curl_xml(SoapXmlBuilder.new(body).to_xml)
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
        body = init_hash_request(token, :GetSignaturesRequest, ACCOUNTSPACE)
        curl_request(body)
      end

      def create_signature(token, name, type, content)
        soap_name = :CreateSignatureRequest
        req = { signature: { name: name, content: { type: type, _content: content } } }
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      def modify_signature(token, id, name, type, content)
        soap_name = :ModifySignatureRequest
        req = { signature: { id: id, name: name, cid: { content: { type: type, _content: content } } } }
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        # puts body
        curl_request(body)
      end

      def delete_signature(token, id)
        soap_name = :DeleteSignatureRequest
        req = { signature: { id: id } }
        body = init_hash_request(token, soap_name, ACCOUNTSPACE)
        body[:Body][soap_name].merge!(req)
        curl_request(body)
      end

      # -------------------------------
      # GENERIC

      def get_info(token, sections = 'mbox', rights = nil)
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
          query: query
        }.merge!(options)
        req.reject! { |_, v| v.nil? }

        body = init_hash_request(token, soap_name)
        body[:Body][soap_name].merge!(req) if req.any?
        # puts body
        curl_request(body)
      end

      private

      def compute_preauth(mail, ts, domainkey)
        data = "#{mail}|name|0|#{ts}"
        digest = OpenSSL::Digest.new('sha1')
        hmac = OpenSSL::HMAC.hexdigest(digest, domainkey, data)
        hmac.to_s
      end

      def init_hash_request(token, soap_name, jsns = MAILSPACE)
        {
          Body: {
            soap_name => { _jsns: jsns }
          }
        }.merge(hash_header(token))
      end

      def init_hash_arrow_request(token, soap_name, jsns = MAILSPACE)
        { Envelope: {
            :@xmlns => 'http://schemas.xmlsoap.org/soap/envelope/',
            '@xmlns:urn' => 'urn:zimbra',
            Header: {
              context: {
                authToken: token,
                :@xmlns => BASESPACE,
                format: {
                    :@type => 'js'
                }
              }
            },
            Body: {
              soap_name => { :@xmlns => jsns }
            }
          }
        }
      end
    end
  end
end
