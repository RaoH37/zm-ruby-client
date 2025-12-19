# frozen_string_literal: true

module Zm
  module Client
    # class for account folder
    class Folder < Base::Object
      include BelongsToFolder
      include RequestMethodsMailbox
      include MailboxItemConcern

      attr_accessor :type, :uuid, :name, :absFolderPath, :url, :luuid, :f, :view, :rev, :ms,
                    :webOfflineSyncDays, :activesyncdisabled, :n, :s, :i4ms, :i4next, :zid, :rid, :ruuid,
                    :owner, :reminder, :acl, :itemCount, :broken, :deletable, :color, :rgb, :fb, :folders

      alias nb_messages n
      alias nb_items n
      alias size s

      def initialize(parent)
        super

        @type = :folder
        @folders = []

        yield(self) if block_given?
      end

      def l
        return @l if defined? @l

        FolderDefault::ROOT.id
      end
      alias folder_id l

      def grants
        return @grants if defined? @grants

        @grants = FolderGrantsCollection.new(self)
      end

      def retention_policies
        return @retention_policies if defined? @retention_policies

        @retention_policies = FolderRetentionPoliciesCollection.new(self)
      end

      def is_immutable?
        return @is_immutable if defined? @is_immutable

        @is_immutable = Zm::Client::FolderDefault::IDS.include?(id.to_i)
      end

      def to_query
        "inid:#{id}"
      end

      def create!
        rep = @parent.soap_connector.invoke(build_create)
        json = rep[:CreateFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
        id
      end

      def color!
        @parent.soap_connector.invoke(build_color)
        true
      end

      def build_color
        jsns_builder.to_color
      end

      def reload!
        rep = @parent.soap_connector.invoke(jsns_builder.to_find)
        json = rep[:GetFolderResponse][:folder].first
        FolderJsnsInitializer.update(self, json)
        true
      end

      def empty?
        @n.zero?
      end

      def empty!
        return false if empty?

        @parent.soap_connector.invoke(build_empty)
        @n = 0
      end
      alias clear empty!

      def build_empty
        jsns_builder.to_empty
      end

      def delete!
        return false if is_immutable? || id.nil?

        @parent.soap_connector.invoke(build_delete)
      end

      def remove_flag!(pattern)
        flags = f.tr(pattern, '')
        update!(f: flags)
      end

      def add_message(eml, d = nil, f = nil, tn = nil)
        @parent.soap_connector.invoke(build_add_message(eml, d, f, tn))
      end

      def build_add_message(eml, d = nil, f = nil, tn = nil)
        m = {
          l: id,
          d: d,
          f: f,
          tn: tn,
          content: { _content: eml }
        }
        m.compact!

        attrs = { m: m }

        SoapElement.mail(SoapMailConstants::ADD_MSG_REQUEST)
                   .add_attributes(attrs)
      end

      def add_appointments(ics)
        @parent.soap_connector.invoke(build_add_appointments(ics)).dig(:ImportAppointmentsResponse, :appt)
      end

      def build_add_appointments(ics)
        attrs = { l: id, ct: SoapConstants::TEXT_CALENDAR }
        soap_request = SoapElement.mail(SoapMailConstants::IMPORT_APPOINTMENTS_REQUEST).add_attributes(attrs)
        node_content = SoapElement.create(SoapConstants::CONTENT).add_content(ics)
        soap_request.add_node(node_content)
        soap_request
      end

      def download(dest_file_path, fmt: nil)
        uploader = @parent.build_uploader
        uploader.download_folder(dest_file_path, id, fmt:)
      end

      def upload(src_file_path, fmt: nil, resolve: nil)
        uploader = @parent.build_uploader
        uploader.send_file(src_file_path, id, fmt:, type: view, resolve:)
      end

      private

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = FolderJsnsBuilder.new(self)
      end
    end
  end
end
