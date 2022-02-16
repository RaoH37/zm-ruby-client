# frozen_string_literal: true

require 'zm/modules/common/dl_common'
module Zm
  module Client
    # objectClass: zimbraDistributionList
    class DistributionList < Base::AdminObject
      attr_accessor :members
      attr_reader :owners

      def initialize(parent)
        extend(DistributionListCommon)
        super(parent)
        @members = []
        @owners = []
        @grantee_type = 'grp'.freeze
      end

      # def to_h
      #   hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
      #   hashmap.delete_if { |_, v| v.nil? }
      #   hashmap
      # end

      def all_instance_variable_keys
        DistributionListCommon::ALL_ATTRS
      end

      def init_from_json(json)
        # puts json
        # @members = json[:a].select { |a| a[:n] == 'zimbraMailForwardingAddress' }.map { |a| a[:_content] }.compact
        @members = json[:dlm].map { |a| a[:_content] }.compact if json[:dlm].is_a?(Array)
        @owners = json[:owners].first[:owner].map { |a| a[:name] }.compact if json[:owners].is_a?(Array)
        super(json)
        @zimbraMailAlias = [@zimbraMailAlias].compact unless @zimbraMailAlias.is_a?(Array)
        @zimbraMailAlias.delete(@name)
        @aliases = @zimbraMailAlias
      end

      def create!
        rep = sac.create_distribution_list(
          @name,
          instance_variables_array(attrs_write)
        )
        @id = rep[:Body][:CreateDistributionListResponse][:dl].first[:id]
      end

      def modify!
        attrs_to_modify = instance_variables_array(attrs_write)
        return if attrs_to_modify.empty?

        sac.modify_distribution_list(@id, attrs_to_modify)
      end

      def update!(hash)
        sac.modify_distribution_list(@id, hash)

        hash.each do |k, v|
          arrow_attr_sym = "@#{k}".to_sym

          if v.respond_to?(:empty?) && v.empty?
            self.remove_instance_variable(arrow_attr_sym) if self.instance_variable_get(arrow_attr_sym)
          else
            self.instance_variable_set(arrow_attr_sym, v)
          end
        end
      end

      def aliases
        @aliases ||= []
      end

      def add_alias!(email)
        sac.add_distribution_list_alias(@id, email)
        aliases.push(email)
      end

      def remove_alias!(email)
        sac.remove_distribution_list_alias(@id, email)
        aliases.delete(email)
      end

      def rename!(email)
        sac.rename_distribution_list(@id, email)
        @name = email
      end

      def delete!
        sac.delete_distribution_list(@id)
      end

      def add_members!(*emails)
        sac.add_distribution_list_members(@id, emails)
        @members += emails
      end

      def remove_members!(*emails)
        sac.remove_distribution_list_members(@id, emails)
        @members -= emails
      end

      def local_transport
        raise Zm::Client::SoapError, 'zimbraMailHost is null' if zimbraMailHost.nil?

        "lmtp:#{zimbraMailHost}:7025"
      end

      def local_transport!
        update!(zimbraMailTransport: local_transport)
      end

      def is_local_transport?
        return nil unless zimbraMailTransport

        zimbraMailTransport.start_with?('lmtp')
      end

      def is_external_transport?
        return nil unless zimbraMailTransport

        zimbraMailTransport.start_with?('smtp')
      end
    end
  end
end
