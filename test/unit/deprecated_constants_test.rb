# frozen_string_literal: true

require_relative '../test_helper'

class DeprecatedConstantsTest < Minitest::Test
  def teardown
    Zm::Client::DeprecatedConstants::NAMES.each_key do |name|
      Zm::Client.send(:remove_const, name) if Zm::Client.const_defined?(name, false)
    end
  end

  def test_every_deprecated_constant_resolves_to_its_new_name
    Zm::Client::DeprecatedConstants::NAMES.each do |name, target|
      capture_io { assert_same Object.const_get(target), Zm::Client.const_get(name) }
    end
  end

  def test_warns_once_with_the_new_name
    _, first = capture_io { Zm::Client::SoapError }
    _, second = capture_io { Zm::Client::SoapError }

    assert_match(/Zm::Client::SoapError is deprecated.*use Zm::Error::SoapError instead/, first)
    assert_includes first, __FILE__
    assert_empty second
  end

  def test_rescue_with_the_old_name
    body = { Body: { Fault: { Reason: { Text: 'boom' }, Detail: { Error: { Code: 'service.FAILURE' } } } } }
    error = nil

    capture_io do
      raise Zm::Error::SoapError, body
    rescue Zm::Client::SoapError => e
      error = e
    end

    assert_equal 'service.FAILURE', error.code
  end

  def test_unknown_constant_still_raises_name_error
    assert_raises(NameError) { Zm::Client::DoesNotExist }
  end
end
