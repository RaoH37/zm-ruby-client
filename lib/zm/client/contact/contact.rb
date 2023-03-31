# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Contact < Base::AccountObject
      GROUP_PATTERN = 'group'

      attr_accessor :anniversary, :assistantPhone, :birthday, :callbackPhone, :carPhone, :company, :companyPhone,
                    :custom1, :department, :email, :email2, :email3, :email4, :email5, :email6, :email7, :firstName,
                    :fullName, :homeCity, :homeCountry, :homeFax, :homePhone, :homePostalCode, :homeState, :homeStreet,
                    :homeURL, :imAddress1, :imAddress2, :imAddress3, :imAddress4, :imAddress5, :jobTitle, :lastName,
                    :maidenName, :middleName, :mobilePhone, :namePrefix, :nameSuffix, :nickname, :notes, :otherCity,
                    :otherCountry, :otherFax, :otherPhone, :otherPostalCode, :otherState, :otherStreet, :otherURL,
                    :pager, :workCity, :workCountry, :workFax, :workPhone, :workPostalCode, :workState, :workStreet,
                    :workURL, :image, :id, :name, :l, :type, :tn

      def group?
        @type == GROUP_PATTERN
      end

      def emails
        [email, email2, email3, email4, email5, email6, email7].compact
      end

      def add_custom_property(key, value)
        instance_variable_set(Utils.arrow_name(key), value)
      end

      def create!
        rep = @parent.sacc.jsns_request(:CreateContactRequest, @parent.token, jsns_builder.to_jsns)
        ContactJsnsInitializer.update(self, rep[:Body][:CreateContactResponse][:cn].first)
        super
      end

      def update!(hash)
        hash.delete_if { |k, v| v.nil? || !respond_to?(k) }
        return false if hash.empty?

        @parent.sacc.jsns_request(:ModifyContactRequest, @parent.token, jsns_builder.to_patch(hash))
        hash.each { |k, v| send(Utils.equals_name(k), v) }
      end

      def modify!
        @parent.sacc.jsns_request(:ModifyContactRequest, @parent.token, jsns_builder.to_update)
      end

      private

      def jsns_builder
        @jsns_builder ||= ContactJsnsBuilder.new(self)
      end
    end
  end
end
