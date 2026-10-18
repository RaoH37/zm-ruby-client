# frozen_string_literal: true

require_relative '../test_helper'

class RestConnectorTest < ZmTest::UnitTest
  def test_download_network_error_raises_connection_error_and_removes_file
    connector = connector_raising(Faraday::TimeoutError.new('timeout'))

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'file.tgz')

      error = assert_raises(Zm::Error::ConnectionError) { connector.download('https://zimbra.test/file', path) }
      assert_instance_of Faraday::TimeoutError, error.cause
      refute File.exist?(path)
    end
  end

  def test_read_network_error_raises_connection_error
    connector = connector_raising(Faraday::ConnectionFailed.new('refused'))

    assert_raises(Zm::Error::ConnectionError) { connector.read('https://zimbra.test/file') }
  end

  private

  def connector_raising(network_error)
    stubs = Faraday::Adapter::Test::Stubs.new { |stub| stub.get('/file') { raise network_error } }
    Zm::Connector::RestConnector.new.tap do |connector|
      connector.define_singleton_method(:conn_get) { |_url| Faraday.new { |f| f.adapter(:test, stubs) } }
    end
  end
end
