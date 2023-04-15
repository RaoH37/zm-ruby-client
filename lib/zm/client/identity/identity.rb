# frozen_string_literal: true

module Zm
  module Client
    # class account identity
    class Identity < Base::Object
      attr_accessor :id, :name, :zimbraPrefIdentityName, :zimbraPrefFromDisplay, :zimbraPrefFromAddress,
                    :zimbraPrefFromAddressType, :zimbraPrefReplyToEnabled, :zimbraPrefReplyToDisplay,
                    :zimbraPrefReplyToAddress, :zimbraPrefDefaultSignatureId, :zimbraPrefForwardReplySignatureId,
                    :zimbraPrefWhenSentToEnabled, :zimbraPrefWhenInFoldersEnabled, :zimbraPrefWhenSentToAddresses

      def create!
        rep = @parent.sacc.jsns_request(:CreateIdentityRequest, @parent.token, jsns_builder.to_jsns, SoapAccountConnector::ACCOUNTSPACE)
        IdentityJsnsInitializer.update(self, rep[:Body][:CreateIdentityResponse][:identity].first)
        @id
      end

      def modify!
        @parent.sacc.jsns_request(:ModifyIdentityRequest, @parent.token, jsns_builder.to_jsns, SoapAccountConnector::ACCOUNTSPACE)
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

      def rename!(new_name)
        raise NotImplementedError
      end

      def delete!
        return if @id.nil?

        @parent.sacc.jsns_request(:DeleteIdentityRequest, @parent.token, jsns_builder.to_delete,
                                  SoapAccountConnector::ACCOUNTSPACE)
        @id = nil
      end

      def clone
        new_identity = super do |obj|
          %i[@zimbraPrefDefaultSignatureId @zimbraPrefForwardReplySignatureId].each do |arrow_key|
            obj.remove_instance_variable(arrow_key) if obj.instance_variable_get(arrow_key)
          end
        end
        yield(new_identity) if block_given?
        new_identity
      end

      private

      def do_update!(hash)
        @parent.sacc.jsns_request(:ModifyIdentityRequest, @parent.token, jsns_builder.to_patch(hash),
                                  SoapAccountConnector::ACCOUNTSPACE)
      end

      def jsns_builder
        @jsns_builder ||= IdentityJsnsBuilder.new(self)
      end
    end
  end
end
