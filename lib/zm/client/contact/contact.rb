# frozen_string_literal: true

module Zm
  module Client
    # class account tag
    class Contact < Base::AccountObject
      INSTANCE_VARIABLE_KEYS = %i[anniversary assistantPhone birthday callbackPhone carPhone company companyPhone custom1 department email email2 email3 email4 email5 email6 email7 firstName fullName homeCity homeCountry homeFax homePhone homePostalCode homeState homeStreet homeURL imAddress1 imAddress2 imAddress3 imAddress4 imAddress5 jobTitle lastName maidenName middleName mobilePhone namePrefix nameSuffix nickname notes otherCity otherCountry otherFax otherPhone otherPostalCode otherState otherStreet otherURL pager workCity workCountry workFax workPhone workPostalCode workState workStreet workURL]

      attr_accessor *INSTANCE_VARIABLE_KEYS
      attr_accessor :id, :name

      def initialize(parent, json = nil)
        @parent = parent
        init_from_json(json) if json.is_a?(Hash)
        yield(self) if block_given?
      end

      def emails
        [email, email2, email3, email4, email5, email6, email7].compact
      end

      def emails_h
        { 'email' => email, 'email2' => email2, 'email3' => email3, 'email4' => email4, 'email5' => email5, 'email6' => email6, 'email7' => email7 }.compact
      end

      def concat
        [@id, @name] + INSTANCE_VARIABLE_KEYS.map { |key| instance_variable_get(arrow_name(key)) }
      end

      def init_from_json(json)
        @id = json[:id]
        @name = json[:fileAsStr]
        INSTANCE_VARIABLE_KEYS.each do |key|
          var_name = "@#{key}"
          instance_variable_set(var_name, json[:_attrs][key])
        end unless json[:_attrs].nil?
      end

      def create!
        #rep = @parent.sacc.create_contact(@parent.token, @name, @color, @rgb)
        #init_from_json(rep[:Body][:CreateContactResponse][:contact].first)
      end

      def delete!
        #@parent.sacc.tag_action(@parent.token, :delete, @id)
      end

      def update!(hash)
        sacc.modify_contact(@parent.token, @id, hash)
        hash.each { |k, v| send "#{k}=", v }
      end

      def modify!
      end
    end
  end
end
