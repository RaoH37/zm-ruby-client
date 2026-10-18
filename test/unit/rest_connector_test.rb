# frozen_string_literal: true

require_relative '../test_helper'

class RestConnectorTest < ZmTest::UnitTest
  # Streams the body through on_data after saving the status, like faraday-net_http.
  class StreamingAdapter < Faraday::Adapter
    def initialize(app, status, chunks)
      super(app)
      @status = status
      @chunks = chunks
    end

    def call(env)
      super
      save_response(env, @status, nil, nil, nil, finished: false)
      env.stream_response { |&on_data| @chunks.each { |chunk| on_data.call(chunk) } }
      env.response_body = +''
      env.response.finish(env)
      @app.call(env)
    end
  end

  ERROR_PAGE = '<html><head><title>Error 404 no such item</title></head><body>not found</body></html>'

  def test_download_writes_streamed_body
    connector = streaming_connector(200, %w[abc def])

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'file.tgz')
      connector.download('https://zimbra.test/file', path)

      assert_equal 'abcdef', File.read(path)
    end
  end

  def test_download_http_error_reports_body_and_removes_file
    connector = streaming_connector(404, [ERROR_PAGE])

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'file.tgz')

      error = assert_raises(Zm::Error::RestError) { connector.download('https://zimbra.test/file', path) }
      assert_equal 'Download failure: Error 404 no such item (status=404)', error.message
      refute File.exist?(path)
    end
  end

  def test_read_returns_streamed_body
    assert_equal 'abcdef', streaming_connector(200, %w[abc def]).read('https://zimbra.test/file')
  end

  def test_read_http_error_reports_body
    connector = streaming_connector(500, ['plain error'])

    error = assert_raises(Zm::Error::RestError) { connector.read('https://zimbra.test/file') }
    assert_equal 'Download failure: plain error (status=500)', error.message
  end

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

  def streaming_connector(status, chunks)
    connector_with { |f| f.adapter(StreamingAdapter, status, chunks) }
  end

  def connector_raising(network_error)
    stubs = Faraday::Adapter::Test::Stubs.new { |stub| stub.get('/file') { raise network_error } }
    connector_with { |f| f.adapter(:test, stubs) }
  end

  def connector_with(&)
    Zm::Connector::RestConnector.new.tap do |connector|
      connector.define_singleton_method(:conn_get) { |url| Faraday.new(url:, &) }
    end
  end
end
