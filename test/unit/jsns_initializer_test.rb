# frozen_string_literal: true

require_relative '../test_helper'

class JsnsInitializerTest < ZmTest::UnitTest
  INITIALIZER = Zm::Client::Base::BaseJsnsInitializer

  def test_formatted_json_groups_multi_valued_attributes
    json = { a: [{ n: 'cn', _content: 'John' }, { n: 'mail', _content: 'a@d.tld' }, { n: 'mail', _content: 'b@d.tld' },
                 { n: 'mail', _content: 'c@d.tld' }, { n: 'empty', _content: nil }, { _content: 'no name' }] }

    expected = { 'cn' => 'John', 'mail' => %w[a@d.tld b@d.tld c@d.tld], 'empty' => nil }
    assert_equal expected, INITIALIZER.formatted_json(json)
  end

  def test_formatted_json_without_attributes
    assert_empty INITIALIZER.formatted_json({})
  end

  def test_convert_json_string_value_matches_integer_round_trip
    values = ['0', '42', '-7', '10737418240', '007', '-0', '+5', '5 ', ' 5', "5\n", '1e3', '4.2', 'abc', '', 'TRUE']
    values.each do |value|
      expected = value.to_i.to_s == value ? value.to_i : value
      assert_equal expected, INITIALIZER.convert_json_string_value(value), value.inspect
    end
    assert_nil INITIALIZER.convert_json_string_value(nil)
    assert_equal %w[1 2], INITIALIZER.convert_json_string_value(%w[1 2])
  end
end
