# frozen_string_literal: true

module Zm
  module Client
    # class account identity
    class Identity < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[id name zimbraPrefIdentityName zimbraPrefFromDisplay zimbraPrefFromAddress
                                  zimbraPrefFromAddressType zimbraPrefReplyToEnabled zimbraPrefReplyToDisplay zimbraPrefReplyToAddress
                                  zimbraPrefDefaultSignatureId zimbraPrefForwardReplySignatureId zimbraPrefWhenSentToEnabled
                                  zimbraPrefWhenInFoldersEnabled zimbraPrefWhenSentToAddresses].freeze

      ATTRS_WRITE = %i[zimbraPrefIdentityName zimbraPrefFromDisplay zimbraPrefFromAddress
                       zimbraPrefFromAddressType zimbraPrefReplyToEnabled zimbraPrefReplyToDisplay zimbraPrefReplyToAddress
                       zimbraPrefDefaultSignatureId zimbraPrefForwardReplySignatureId zimbraPrefWhenSentToEnabled
                       zimbraPrefWhenInFoldersEnabled zimbraPrefWhenSentToAddresses].freeze

      attr_accessor(*INSTANCE_VARIABLE_KEYS)

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS
      end

      def init_from_json(json)
        @id    = json[:id]
        @name  = json[:name]
        all_instance_variable_keys.each do |key|
          value = json[:_attrs][key]
          next if value.nil?

          instance_variable_set(arrow_name(key), value)
        end
      end

      def create!
        rep = @parent.sacc.create_identity(@parent.token, name, instance_variables_array(ATTRS_WRITE))
        init_from_json(rep[:Body][:CreateIdentityResponse][:identity].first)
      end

      def update!(hash)
        return false if hash.delete_if { |k, v| v.nil? || !respond_to?(k) }.empty?

        @parent.sacc.modify_identity(@parent.token, id, hash)

        hash.each do |key, value|
          update_attribute(key, value)
        end

        true
      end

      def modify!
        @parent.sacc.modify_identity(@parent.token, id, instance_variables_array(ATTRS_WRITE))
      end

      def delete!
        @parent.sacc.delete_identity(@parent.token, @id)
        super
      end

      def rename!(new_name); end

      def clone
        new_identity = super do |obj|
          %i[@zimbraPrefDefaultSignatureId @zimbraPrefForwardReplySignatureId].each do |arrow_key|
            obj.remove_instance_variable(arrow_key) if obj.instance_variable_get(arrow_key)
          end
        end
        yield(new_identity) if block_given?
        new_identity
      end
    end
  end
end
