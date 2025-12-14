# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Contact < Base::Object
      include BelongsToFolder
      include BelongsToTag
      include RequestMethodsMailbox
      include MailboxItemConcern

      GROUP_PATTERN = 'group'

      attr_accessor :anniversary, :assistantPhone, :birthday, :callbackPhone, :carPhone, :company,
                    :companyPhone, :custom1, :department, :email, :email2, :email3, :email4, :email5,
                    :email6, :email7, :firstName, :fullName, :homeCity, :homeCountry, :homeFax,
                    :homePhone, :homePostalCode, :homeState, :homeStreet, :homeURL, :imAddress1,
                    :imAddress2, :imAddress3, :imAddress4, :imAddress5, :jobTitle, :lastName,
                    :maidenName, :middleName, :mobilePhone, :namePrefix, :nameSuffix, :nickname, :notes,
                    :otherCity, :otherCountry, :otherFax, :otherPhone, :otherPostalCode, :otherState,
                    :otherStreet, :otherURL, :pager, :workCity, :workCountry, :workFax, :workPhone,
                    :workPostalCode, :workState, :workStreet, :workURL, :image, :name, :type,
                    :tn, :shared_account_id, :shared_folder_account_id

      def initialize(parent)
        @l = FolderDefault::CONTACTS.id
        @shared_account_id = nil
        @shared_folder_account_id = nil
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
        rep = @parent.soap_connector.invoke(build_create)
        ContactJsnsInitializer.update(self, rep[:CreateContactResponse][:cn].first)

        id
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
      end

      def reload!
        raise NotImplementedError
      end

      private

      def jsns_builder
        return @jsns_builder if defined? @jsns_builder

        @jsns_builder = ContactJsnsBuilder.new(self)
      end
    end
  end
end
