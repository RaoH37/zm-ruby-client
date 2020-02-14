# frozen_string_literal: true

module Zm
  module Client
    # class account identity
    class Identity < Base::AccountObject

      INSTANCE_VARIABLE_KEYS = %i[id name zimbraPrefIdentityName zimbraPrefFromDisplay zimbraPrefFromAddress
        zimbraPrefFromAddressType zimbraPrefReplyToEnabled zimbraPrefReplyToDisplay zimbraPrefReplyToAddress
        zimbraPrefDefaultSignatureId zimbraPrefForwardReplySignatureId zimbraPrefWhenSentToEnabled
        zimbraPrefWhenInFoldersEnabled]

      ATTRS_WRITE = %i[zimbraPrefIdentityName zimbraPrefFromDisplay zimbraPrefFromAddress
        zimbraPrefFromAddressType zimbraPrefReplyToEnabled zimbraPrefReplyToDisplay zimbraPrefReplyToAddress
        zimbraPrefDefaultSignatureId zimbraPrefForwardReplySignatureId zimbraPrefWhenSentToEnabled
        zimbraPrefWhenInFoldersEnabled]

      attr_accessor *INSTANCE_VARIABLE_KEYS

      def concat
        INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def init_from_json(json)
        super(json)
        INSTANCE_VARIABLE_KEYS.each do |key|
          value = json[:_attrs][key]
          next if value.nil?

          instance_variable_set(arrow_name(key), value)
        end
      end

      def create!
        rep = @parent.sacc.create_identity(@parent.token, name, instance_variables_array(ATTRS_WRITE))
        init_from_json(rep[:Body][:CreateIdentityResponse][:identity].first)
      end

      def modify!
        @parent.sacc.modify_identity(@parent.token, id, instance_variables_array(ATTRS_WRITE))
      end

      def delete!
        @parent.sacc.delete_identity(@parent.token, id)
      end

      def rename!(new_name)
      end

      def clone
        new_identity = super do |obj|
          [:@zimbraPrefDefaultSignatureId, :@zimbraPrefForwardReplySignatureId].each do |arrow_key|
            obj.remove_instance_variable(arrow_key) if obj.instance_variable_get(arrow_key)
          end
        end
        yield(new_identity) if block_given?
        new_identity
      end
    end
  end
end
