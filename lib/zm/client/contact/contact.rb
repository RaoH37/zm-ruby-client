# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Contact < Base::AccountObject

      GROUP_PATTERN = 'group'.freeze

      INSTANCE_VARIABLE_KEYS = %i[
        anniversary assistantPhone birthday callbackPhone carPhone company companyPhone custom1 department email email2
        email3 email4 email5 email6 email7 firstName fullName homeCity homeCountry homeFax homePhone homePostalCode
        homeState homeStreet homeURL imAddress1 imAddress2 imAddress3 imAddress4 imAddress5 jobTitle lastName maidenName
        middleName mobilePhone namePrefix nameSuffix nickname notes otherCity otherCountry otherFax otherPhone
        otherPostalCode otherState otherStreet otherURL pager workCity workCountry workFax workPhone workPostalCode
        workState workStreet workURL
      ]

      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_accessor :id, :name, :l, :type, :members, :tn

      def initialize(parent, json = nil)
        @parent = parent
        @members    = []
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
        { 'email' => email, 'email2' => email2, 'email3' => email3, 'email4' => email4, 'email5' => email5, 'email6' => email6, 'email7' => email7 }.compact
      end

      def concat
        [id, name, l] + INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def init_from_json(json)
        puts json
        @id = json[:id]
        @name = json[:fileAsStr]
        @l = json[:l]
        @tn = json[:tn]

        unless json[:_attrs].nil?
          @type = json[:_attrs][:type]

          INSTANCE_VARIABLE_KEYS.each do |key|
            var_name = "@#{key}"
            instance_variable_set(var_name, json[:_attrs][key])
          end
        end

        if is_group? && !json[:m].nil?
          @members = json[:m].map{|m| ConcatMember.new(m[:type], m[:value]) }
        end
      end

      def create!
        rep = @parent.sacc.create_contact(@parent.token, l, instance_variables_array(INSTANCE_VARIABLE_KEYS))
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
        @parent.sacc.modify_contact(@parent.token, id, instance_variables_array(INSTANCE_VARIABLE_KEYS))
      end

      def add_members(members)
        @members += members
      end

      def delete_members(members)
        @members -= members
      end

      def ldap_members
        return [] if @members.nil?

        @members.select(&:ldap?)
      end

      def has_ldap_members?
        ldap_members.any?
      end

      def construct_soap_node_members
        if recorded?
          (@old_members - @members).each(&:remove!)
          (@members - @old_members).each(&:add!)
          (@old_members + @members).uniq.reject { |m| m.op.nil? }.map(&:construct_soap_node)
        else
          @members.map(&:construct_soap_node)
        end
      end
    end
  end
end