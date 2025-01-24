# frozen_string_literal: true

module Zm
  module Client
    # class account data source
    class DataSource < Base::Object
      include RequestMethodsMailbox

      TYPES = %i[cal caldav yab gal imap pop3 rss unknown].freeze

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

      def build_create
        raise NotImplementedError
      end

      def modify!
        raise NotImplementedError
      end

      def build_modify
        raise NotImplementedError
      end

      def rename!(*args)
        raise NotImplementedError
      end

      def build_rename(*args)
        raise NotImplementedError
      end

      private

      def jsns_builder
        @jsns_builder ||= DataSourceJsnsBuilder.new(self)
      end
    end
  end
end
