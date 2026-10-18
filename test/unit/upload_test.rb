# frozen_string_literal: true

require_relative '../test_helper'

class UploadTest < ZmTest::UnitTest
  BASE_URL = 'https://mail.domain.tld:443/home/user@domain.tld'

  def setup
    super
    @upload = Zm::Client::Upload.new(BASE_URL, 'token')
  end

  def test_url_params_are_encoded
    url = @upload.download_file_url('tgz', 'message', 'a&b=c#d')

    assert_includes url, 'id=a%26b%3Dc%23d'
    refute_includes url, 'a&b'
  end

  def test_upload_attachment_url
    assert_equal 'https://mail.domain.tld:443/home/user@domain.tld/service/upload?fmt=extended%2Craw',
                 @upload.upload_attachment_url
  end

  def test_download_file_with_url_rejects_other_origin
    %w[https://evil.tld/file http://mail.domain.tld/file https://mail.domain.tld:8443/file].each do |url|
      assert_raises(Zm::Error::RestError) { @upload.download_file_with_url(url, File::NULL) }
    end
  end

  def test_same_origin
    assert @upload.same_origin?('https://mail.domain.tld/home/user@domain.tld/?id=1')
    refute @upload.same_origin?('https://mail.domain.tld.evil.tld/home')
  end
end
