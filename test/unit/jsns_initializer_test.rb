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

  def test_each_attribute_groups_multi_valued_attributes
    json = { a: [{ n: 'cn', _content: 'John' }, { n: 'mail', _content: 'a@d.tld' }, { n: 'mail', _content: 'b@d.tld' },
                 { n: 'empty', _content: nil }, { _content: 'no name' }, { n: 'mail2', _content: 'c@d.tld' }] }

    pairs = []
    INITIALIZER.each_attribute(json[:a]) { |key, value| pairs << [key, value] }

    assert_equal [['cn', 'John'], ['mail', %w[a@d.tld b@d.tld]], ['empty', nil], ['mail2', 'c@d.tld']], pairs
  end

  def test_update_sets_the_zimbra_attributes
    json = { id: 'id-1', name: 'user@domain.tld', a: [
      { n: 'zimbraMailQuota', _content: '1073741824' }, { n: 'zimbraMailAlias', _content: 'a@domain.tld' },
      { n: 'zimbraMailAlias', _content: 'b@domain.tld' }, { n: 'unknownAttr', _content: 'x' }
    ] }

    account = Zm::Client::AccountJsnsInitializer.create(logged_cluster, json)

    assert_equal ['id-1', 'user@domain.tld', 1_073_741_824, %w[a@domain.tld b@domain.tld]],
                 [account.id, account.name, account.zimbraMailQuota, account.zimbraMailAlias]
    refute_includes account.instance_variables, :@unknownAttr
    refute account.zimbra_attrs_changed?
  end
end
