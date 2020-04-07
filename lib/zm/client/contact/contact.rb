# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Contact < Base::AccountObject
      GROUP_PATTERN = 'group'

      INSTANCE_VARIABLE_KEYS = %i[
        anniversary assistantPhone birthday callbackPhone carPhone company companyPhone custom1 department email email2
        email3 email4 email5 email6 email7 firstName fullName homeCity homeCountry homeFax homePhone homePostalCode
        homeState homeStreet homeURL imAddress1 imAddress2 imAddress3 imAddress4 imAddress5 jobTitle lastName maidenName
        middleName mobilePhone namePrefix nameSuffix nickname notes otherCity otherCountry otherFax otherPhone
        otherPostalCode otherState otherStreet otherURL pager workCity workCountry workFax workPhone workPostalCode
        workState workStreet workURL image
      ].freeze

      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_accessor :id, :name, :l, :type, :members, :old_members, :tn

      def initialize(parent, json = nil)
        @parent  = parent
        @members = []
        @custom_keys = []
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
        @old_members = @members.clone
      end

      def is_group?
        @type == GROUP_PATTERN
      end

      def emails
        [email, email2, email3, email4, email5, email6, email7].compact
      end

      def emails_h
        {
            'email' => email,
            'email2' => email2,
            'email3' => email3,
            'email4' => email4,
            'email5' => email5,
            'email6' => email6,
            'email7' => email7
        }.compact
      end

      def concat
        [id, name, l] + all_instance_variable_keys.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def to_h
        hashmap = Hash[all_instance_variable_keys.map { |key| [key, instance_variable_get(arrow_name(key))] }]
        hashmap.delete_if { |_, v| v.nil? }
        hashmap
      end

      def init_from_json(json)
        @id   = json[:id]
        @name = json[:fileAsStr]
        @l    = json[:l]
        @tn   = json[:tn]

        init_instance_variable_from_json(json[:_attrs])

        return unless is_group?

        extend(GroupContact)
        init_members_from_json(json[:m])
      end

      def init_instance_variable_from_json(json_attrs)
        return if json_attrs.nil?

        @type = json_attrs[:type]

        make_custom_keys(json_attrs)

        all_instance_variable_keys.each do |key|
          instance_variable_set(arrow_name(key), json_attrs[key])
        end
      end

      def make_custom_keys(json_attrs)
        @custom_keys = json_attrs.keys - INSTANCE_VARIABLE_KEYS - %i[type fileAs]
        return if @custom_keys.empty?

        self.class.attr_accessor(*@custom_keys)
      end

      def all_instance_variable_keys
        INSTANCE_VARIABLE_KEYS + @custom_keys
      end

      def add_custom_property(key, value)
        instance_variable_set(arrow_name(key), value)
        @custom_keys << key unless all_instance_variable_keys.include?(key)
      end

      def create!
        rep = @parent.sacc.create_contact(@parent.token, l, instance_variables_array(all_instance_variable_keys))
        init_from_json(rep[:Body][:CreateContactResponse][:cn].first)
      end

      def delete!
        @parent.sacc.contact_action(@parent.token, :delete, id)
      end

      def update!(hash)
        @parent.sacc.modify_contact(@parent.token, id, hash)
        hash.each { |k, v| send "#{k}=", v }
      end

      def modify!
        @parent.sacc.modify_contact(@parent.token, id, instance_variables_array(all_instance_variable_keys))
      end
    end
  end
end
