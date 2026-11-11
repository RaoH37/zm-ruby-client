# frozen_string_literal: true

require_relative '../test_helper'

class BackupsResponseTest < ZmTest::UnitTest
  def setup
    super
    @server = Zm::Client::Server.new(logged_cluster) { |server| server.id = 'server-id' }
  end

  def test_all_returns_a_backups_response
    backup_query(%w[full-1 full], %w[incr-1 incremental])

    backups = @server.backups.all

    assert_instance_of Zm::Client::BackupsResponse, backups
    assert_equal %w[full-1 incr-1], backups.map(&:label)
  end

  def test_fulls_and_incrementals
    backup_query(%w[full-1 full], %w[incr-1 incremental], %w[incr-2 incremental], %w[full-2 full])
    backups = @server.backups.all

    assert_instance_of Zm::Client::BackupsResponse, backups.fulls
    assert_equal %w[full-1 full-2], backups.fulls.map(&:label)
    assert_instance_of Zm::Client::BackupsResponse, backups.incrementals
    assert_equal %w[incr-1 incr-2], backups.incrementals.map(&:label)
  end

  def test_empty_response
    @fake.on(:BackupQueryRequest, { BackupQueryResponse: {} })

    backups = @server.backups.all

    assert_instance_of Zm::Client::BackupsResponse, backups
    assert_empty backups.fulls
    assert_empty backups.incrementals
  end

  private

  def backup_query(*backups)
    json = backups.map { |label, type| { label:, type: } }
    @fake.on(:BackupQueryRequest, { BackupQueryResponse: { backup: json } })
  end
end
