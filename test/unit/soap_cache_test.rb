# frozen_string_literal: true

require_relative '../test_helper'

class SoapCacheTest < ZmTest::UnitTest
  def setup
    super
    @dir = Dir.mktmpdir
    @config = build_config
    @config.cache_store = :file_store, { cache_path: @dir }
    @fake.on(:AuthRequest, ZmTest::FakeData.auth_response)
    @cluster = Zm::Client::Cluster.new(@config).tap(&:login)
  end

  def teardown
    FileUtils.rm_rf(@dir)
    super
  end

  def test_read_requests_are_cached
    @fake.on(:GetVersionInfoRequest, { GetVersionInfoResponse: {} })

    2.times { @cluster.soap_admin_connector.invoke(admin_request('GetVersionInfoRequest')) }

    assert_equal 1, request_count('GetVersionInfoRequest')
  end

  def test_write_requests_are_not_cached
    @fake.on(:CreateCosRequest, { CreateCosResponse: {} })

    2.times { @cluster.soap_admin_connector.invoke(admin_request('CreateCosRequest')) }

    assert_equal 2, request_count('CreateCosRequest')
  end

  def test_auth_requests_are_not_cached
    @cluster.login

    assert_equal 2, request_count('AuthRequest')
  end

  def test_cache_files_are_private
    @fake.on(:GetVersionInfoRequest, { GetVersionInfoResponse: {} })
    @cluster.soap_admin_connector.invoke(admin_request('GetVersionInfoRequest'))

    files = Dir.glob(File.join(@dir, '**', '*'))
    refute_empty files
    files.each do |path|
      assert_equal File.directory?(path) ? 0o700 : 0o600, File.stat(path).mode & 0o777, path
    end
  end

  private

  def request_count(name)
    @fake.requests.count { |r| r.name == name }
  end

  def admin_request(name)
    Zm::SoapRequest::SoapElement.admin(name)
  end
end
