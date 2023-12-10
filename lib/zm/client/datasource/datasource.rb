# frozen_string_literal: true

module Zm
  module Client
    # class account data source
    class DataSource < Base::Object
      TYPES = %i[cal caldav yab gal imap pop3 rss unknown]

      attr_accessor :a, :cconnectionType, :cdefaultSignature, :cemailAddress, :cfailingSince, 
                    :cforwardReplySignature, :cfromDisplay, :chost, :cid, :cimportClass, :cimportOnly, 
                    :cisEnabled, :cl, :clientId, :clientSecret, :cname, :connectionType, :cpassword, 
                    :cpollingInterval, :cport, :crefreshToken, :crefreshTokenUrl, :creplyToAddress, 
                    :creplyToDisplay, :csmtpAuthRequired, :csmtpConnectionType, :csmtpEnabled, :csmtpHost, 
                    :csmtpPassword, :csmtpPort, :csmtpUsername, :cuseAddressForForwardReply, :cusername, 
                    :defaultSignature, :emailAddress, :failingSince, :forwardReplySignature, :fromDisplay, 
                    :host, :id, :importClass, :importOnly, :isEnabled, :l, :lastError, :leaveOnServer, :name, 
                    :oauthToken, :password, :pollingInterval, :port, :refreshToken, :refreshTokenUrl, 
                    :replyToAddress, :replyToDisplay, :smtpAuthRequired, :smtpConnectionType, :smtpEnabled, 
                    :smtpHost, :smtpPassword, :smtpPort, :smtpUsername, :test, :useAddressForForwardReply, :username,
                    :type

      def initialize(parent, data_source_type)
        @type = data_source_type
        super(parent)
      end

      def create!
        raise NotImplementedError
      end

      def modify!
        raise NotImplementedError
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
        return false if @id.nil?

        @parent.sacc.invoke(jsns_builder.to_delete)
        @id = nil
      end

      private

      def do_update!(hash)
        @parent.sacc.invoke(jsns_builder.to_patch(hash))
      end

      def jsns_builder
        @jsns_builder ||= DataSourceJsnsBuilder.new(self)
      end
    end
  end
end