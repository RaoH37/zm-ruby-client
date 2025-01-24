# frozen_string_literal: true

module Zm
  module Client
    # class account identity
    class Identity < Base::Object
      include RequestMethodsMailbox

      attr_accessor :id, :name, :zimbraPrefIdentityName, :zimbraPrefFromDisplay, :zimbraPrefFromAddress,
                    :zimbraPrefFromAddressType, :zimbraPrefReplyToEnabled, :zimbraPrefReplyToDisplay,
                    :zimbraPrefReplyToAddress, :zimbraPrefDefaultSignatureId, :zimbraPrefForwardReplySignatureId,
                    :zimbraPrefWhenSentToEnabled, :zimbraPrefWhenInFoldersEnabled, :zimbraPrefWhenSentToAddresses

      def create!
        rep = @parent.sacc.invoke(build_create)
        IdentityJsnsInitializer.update(self, rep[:CreateIdentityResponse][:identity].first)
        @id
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
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

      def jsns_builder
        @jsns_builder ||= IdentityJsnsBuilder.new(self)
      end
    end
  end
end
