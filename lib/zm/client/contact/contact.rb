# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Contact < Base::Object
      include BelongsToFolder
      include BelongsToTag

      GROUP_PATTERN = 'group'

      attr_accessor :anniversary, :assistantPhone, :birthday, :callbackPhone, :carPhone, :company, :companyPhone,
                    :custom1, :department, :email, :email2, :email3, :email4, :email5, :email6, :email7, :firstName,
                    :fullName, :homeCity, :homeCountry, :homeFax, :homePhone, :homePostalCode, :homeState, :homeStreet,
                    :homeURL, :imAddress1, :imAddress2, :imAddress3, :imAddress4, :imAddress5, :jobTitle, :lastName,
                    :maidenName, :middleName, :mobilePhone, :namePrefix, :nameSuffix, :nickname, :notes, :otherCity,
                    :otherCountry, :otherFax, :otherPhone, :otherPostalCode, :otherState, :otherStreet, :otherURL,
                    :pager, :workCity, :workCountry, :workFax, :workPhone, :workPostalCode, :workState, :workStreet,
                    :workURL, :image, :id, :name, :l, :type, :tn
      def initialize(parent)
        @l = FolderDefault::CONTACTS[:id]
        super(parent)
      end

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
        @id
      end

      def modify!
        @parent.sacc.jsns_request(:ModifyContactRequest, @parent.token, jsns_builder.to_update)
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

      def rename!(*args)
        raise NotImplementedError
      end

      def delete!
        return false if @id.nil?

        @parent.sacc.jsns_request(:ItemActionRequest, @parent.token, jsns_builder.to_delete)
        @id = nil
      end

      def reload!
        raise NotImplementedError
      end

      private

      def do_update!(hash)
        @parent.sacc.jsns_request(:ModifyContactRequest, @parent.token, jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= ContactJsnsBuilder.new(self)
      end
    end
  end
end
