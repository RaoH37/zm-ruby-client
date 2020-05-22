# frozen_string_literal: true

require 'zm/modules/common/cos_common'
module Zm
  module Client
    # objectClass: zimbraCos
    class Cos < Base::AdminObject
      def initialize(parent)
        extend(CosCommon)
        super(parent)
      end

      def init_from_json(json)
        super(json)
        @zimbraMailHostPool = [@zimbraMailHostPool] if @zimbraMailHostPool.is_a?(String)
        @zimbraZimletAvailableZimlets = [@zimbraZimletAvailableZimlets] if @zimbraZimletAvailableZimlets.is_a?(String)
      end

      def to_h
        hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def all_instance_variable_keys
        attrs_write
      end

      def duplicate(attrs = {})
        # n = clone
        # attrs.each{|k,v| n.instance_variable_set(k, v) }
        # n.id = nil
        # n.zimbraId = nil
        # n
      end

      def modify!
        # sac.modify_cos(id, instance_variables_array)
      end

      def create!
        sac.create_cos(name, instance_variables_array(attrs_write))
      end

      def servers
        @servers ||= read_servers
      end

      private

      def read_servers
        sc = ServersCollection.new self
        @zimbraMailHostPool.map do |server_id|
          sc.find_by id: server_id
        end
      end
    end
  end
end
