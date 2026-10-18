# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'minitest/autorun'
require 'securerandom'
require 'zm-ruby-client'

module ZmTest
  class LiveTest < Minitest::Test
    ENV_KEYS = %w[ZIMBRA_ADMIN_URL ZIMBRA_ADMIN_LOGIN ZIMBRA_ADMIN_PASSWORD].freeze

    class << self
      def missing_env_keys
        @missing_env_keys ||= ENV_KEYS.select { |key| ENV.fetch(key, '').empty? }
      end

      def cluster
        @cluster ||= Zm::Client::Cluster.new(config).tap(&:login)
      end

      private

      def config
        Zm::Client::ClusterConfig.new(
          zimbra_admin_url: ENV.fetch('ZIMBRA_ADMIN_URL'),
          zimbra_admin_login: ENV.fetch('ZIMBRA_ADMIN_LOGIN'),
          zimbra_admin_password: ENV.fetch('ZIMBRA_ADMIN_PASSWORD')
        ) do |config|
          config.log_path = ENV.fetch('ZIMBRA_LOG_PATH', File::NULL)
        end
      end
    end

    def before_setup
      super
      missing = LiveTest.missing_env_keys
      skip "live tests need #{missing.join(', ')}" unless missing.empty?

      @created = []
    end

    def after_teardown
      @created&.reverse_each do |item|
        next if item.id.nil?

        item.delete!
      rescue Zm::Error::SoapError
        nil
      end
      super
    end

    def cluster
      LiveTest.cluster
    end

    def track(item)
      @created << item
      item
    end

    def unique_name(prefix = 'zmlive')
      "#{prefix}-#{Time.now.strftime('%Y%m%d%H%M%S')}-#{SecureRandom.hex(3)}"
    end

    def unique_email(prefix = 'zmlive')
      "#{unique_name(prefix)}@#{domain.name}"
    end

    def domain
      @domain ||= track(cluster.domains.new { |dom| dom.name = "#{unique_name}.test" }.tap(&:save!))
    end

    def account
      @account ||= track(
        cluster.accounts.new do |acc|
          acc.name = unique_email
          acc.password = SecureRandom.alphanumeric(24)
        end.tap(&:save!)
      )
    end

    def eml(subject: 'Live Test', to: 'recipient@example.com')
      <<~EML
        From: sender@example.com
        To: #{to}
        Subject: #{subject}
        Date: #{Time.now.utc.strftime('%a, %d %b %Y %H:%M:%S +0000')}
        Content-Type: text/plain; charset=utf-8

        Live Test body
      EML
    end
  end
end
