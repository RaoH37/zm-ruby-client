# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class Folder < Base::Object
      include BelongsToFolder
      include RequestMethodsMailbox
      # include Zm::Model::AttributeChangeObserver

      attr_accessor :type, :owner, :reminder, :acl, :folders, :grants, :retention_policies

      extend Philosophal::Properties

      cprop :type, String, default: :folder
      cprop :id, Integer
      cprop :uuid, String
      cprop :name, String
      cprop :absFolderPath, Pathname
      cprop :l, Integer, default: FolderDefault::ROOT[:id]
      cprop :luuid, String
      cprop :f, String
      cprop :color, Integer
      cprop :rgb, String
      cprop :u, Integer
      cprop :view, String, default: FolderView::MESSAGE
      cprop :rev, Integer
      cprop :ms, Integer
      cprop :md, Integer
      cprop :n, Integer
      cprop :i4n, Integer
      cprop :s, Integer
      cprop :i4ms, Integer
      cprop :i4next, Integer
      cprop :url, String
      cprop :webOfflineSyncDays, Integer
      cprop :activesyncdisabled, _Boolean
      cprop :zid, String
      cprop :rid, String
      cprop :ruuid, String
      cprop :recursive, Integer
      cprop :rest, String
      cprop :deletable, _Boolean
      cprop :itemCount, Integer
      cprop :broken, Integer
      cprop :fb, Integer

      alias nb_messages n
      alias nb_items n
      alias size s

      def initialize(parent)
        super(parent)

        # self.l = FolderDefault::ROOT[:id]
        # self.type = :folder
        @folders = []
        @grants = FolderGrantsCollection.new(self)
        @retention_policies = FolderRetentionPoliciesCollection.new(self)

        yield(self) if block_given?
      end

      def is_immutable?
        @is_immutable ||= Zm::Client::FolderDefault::IDS.include?(self.id)
      end

      def to_query
        "inid:#{id}"
      end

      def create!
        rep = @parent.sacc.invoke(build_create)
        json = rep[:CreateFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
        @id
      end

      def color!
        @parent.sacc.invoke(build_color)
        true
      end

      def build_color
        jsns_builder.to_color
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

        @parent.sacc.invoke(build_empty)
        @n = 0
      end
      alias clear empty!

      def build_empty
        jsns_builder.to_empty
      end

      def delete!
        return false if is_immutable? || @id.nil?

        @parent.sacc.invoke(build_delete)
        @id = nil
      end

      def remove_flag!(pattern)
        flags = f.tr(pattern, '')
        update!(f: flags)
      end

      def add_message(eml, d = nil, f = nil, tn = nil)
        @parent.sacc.invoke(build_add_message(eml, d, f, tn))
      end

      def build_add_message(eml, d = nil, f = nil, tn = nil)
        m = {
          l: id,
          d: d,
          f: f,
          tn: tn,
          content: { _content: eml }
        }.reject { |_, v| v.nil? }

        attrs = { m: m }

        SoapElement.mail(SoapMailConstants::ADD_MSG_REQUEST).add_attributes(attrs)
      end

      def add_appointments(ics)
        @parent.sacc.invoke(build_add_appointments(ics)).dig(:ImportAppointmentsResponse, :appt)
      end

      def build_add_appointments(ics)
        attrs = { l: id, ct: SoapConstants::TEXT_CALENDAR }
        soap_request = SoapElement.mail(SoapMailConstants::IMPORT_APPOINTMENTS_REQUEST).add_attributes(attrs)
        node_content = SoapElement.create(SoapConstants::CONTENT).add_content(ics)
        soap_request.add_node(node_content)
        soap_request
      end

      def download(dest_file_path, fmt = 'tgz')
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.download_folder(@id, fmt, dest_file_path)
      end

      def upload(file_path, fmt = nil, types = nil, resolve = 'replace')
        fmt ||= File.extname(file_path)[1..]
        uploader = Upload.new(@parent, RestAccountConnector.new)
        uploader.send_file(absFolderPath, fmt, types, resolve, file_path)
      end

      private

      def jsns_builder
        @jsns_builder ||= FolderJsnsBuilder.new(self)
      end
    end
  end
end
