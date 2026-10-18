# frozen_string_literal: true

require_relative '../test_helper'
require 'open3'

class AutoloadTest < Minitest::Test
  LIB_PATH = File.expand_path('../../lib', __dir__)

  # Runs in a fresh process: other tests may already have loaded the constants.
  SCRIPT = <<~RUBY
    require 'zm-ruby-client'
    namespaces = [Zm, Zm::Client, Zm::Client::Base, Zm::Utils, Zm::Connector, Zm::Error, Zm::Support,
                  Zm::Support::Cache, Zm::SoapRequest]
    undeclared = namespaces.flat_map do |namespace|
      before = namespace.constants(false)
      before.each { |name| namespace.const_get(name) if namespace.autoload?(name) }
      (namespace.constants(false) - before).map { |name| "\#{namespace}::\#{name}" }
    end
    puts undeclared.sort
  RUBY

  def test_every_constant_is_declared_with_autoload
    output, status = Open3.capture2e(RbConfig.ruby, '-I', LIB_PATH, '-e', SCRIPT)

    assert status.success?, output
    assert_empty output.split("\n"), 'constants defined without their own autoload'
  end
end
