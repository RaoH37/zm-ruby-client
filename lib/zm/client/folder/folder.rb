# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class Folder < Base::Object
      include BelongsToFolder
      include Zm::Model::AttributeChangeObserver

      attr_accessor :type, :id, :uuid, :name, :absFolderPath, :l, :url, :luuid, :f, :view, :rev, :ms,
                    :webOfflineSyncDays, :activesyncdisabled, :n, :s, :i4ms, :i4next, :zid, :rid, :ruuid, :owner, :reminder, :acl, :itemCount, :broken, :deletable, :color, :rgb, :fb, :folders, :grants, :retention_policies

      define_changed_attributes :name, :color, :rgb, :l, :url, :f, :view

      alias nb_messages n
      alias nb_items n
      alias size s

      def initialize(parent)
        super(parent)

        @l = FolderDefault::ROOT[:id]
        @type = :folder
        @folders = []
        @grants = FolderGrantsCollection.new(self)
        @retention_policies = FolderRetentionPoliciesCollection.new(self)

        yield(self) if block_given?

        extend(DocumentFolder) if view == Zm::Client::FolderView::DOCUMENT
      end

      def is_immutable?
        @is_immutable ||= Zm::Client::FolderDefault::IDS.include?(@id.to_i)
      end

      def to_query
        "inid:#{id}"
      end

      def create!
        rep = @parent.sacc.invoke(jsns_builder.to_jsns)
        json = rep[:CreateFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
        @id
      end

      def modify!
        @parent.sacc.invoke(jsns_builder.to_update)
        true
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        do_update!(hash)

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def color!
        @parent.sacc.invoke(jsns_builder.to_color) if color_changed? || rgb_changed?

        true
      end

      def rename!(new_name)
        return false if new_name == @name

        @parent.sacc.invoke(jsns_builder.to_rename(new_name))
        @name = new_name
      end

      def reload!
        rep = @parent.sacc.invoke(jsns_builder.to_find)
        json = rep[:GetFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
        true
      end

      def empty?
        @n.zero?
      end

      def empty!
        return false if empty?

        @parent.sacc.invoke(jsns_builder.to_empty)
        @n = 0
      end
      alias clear empty!

      def delete!
        return false if is_immutable? || @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
      end

      def remove_flag!(pattern)
        flags = f.tr(pattern, '')
        update!(f: flags)
      end

      def upload(file_path, fmt = nil, types = nil, resolve = 'replace')
        fmt ||= File.extname(file_path)[1..]
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.send_file(absFolderPath, fmt, types, resolve, file_path)
      end

      def import(file_path)
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.send_file(absFolderPath, 'tgz', nil, 'skip', file_path)
      end

      def add_message(eml, d = nil, f = nil, tn = nil)
        m = {
          l: id,
          d: d,
          f: f,
          tn: tn,
          content: { _content: eml }
        }.reject { |_, v| v.nil? }

        attrs = { m: m }

        soap_request = SoapElement.mail(SoapMailConstants::ADD_MSG_REQUEST).add_attributes(attrs)
        @parent.sacc.invoke(soap_request)
      end

      def add_appointments(ics)
        attrs = { l: id, ct: SoapConstants::TEXT_CALENDAR }
        soap_request = SoapElement.mail(SoapMailConstants::IMPORT_APPOINTMENTS_REQUEST).add_attributes(attrs)
        node_content = SoapElement.create(SoapConstants::CONTENT).add_content(ics)
        soap_request.add_node(node_content)
        @parent.sacc.invoke(soap_request).dig(:ImportAppointmentsResponse, :appt)
      end

      def download(dest_file_path, fmt = 'tgz')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_folder(@id, fmt, dest_file_path)
      end

      def export(dest_file_path)
        h = {
          fmt: 'tgz',
          emptyname: 'Vide',
          charset: 'UTF-8',
          auth: 'qp',
          zauthtoken: @parent.token
        }

        url_query = "#{absFolderPath}?#{Utils.format_url_params(h)}"

        @parent.uploader.download_file_with_url(url_query, dest_file_path)
      end

      private

      def do_update!(hash)
        @parent.sacc.invoke(jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= FolderJsnsBuilder.new(self)
      end
    end
  end
end
