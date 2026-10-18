# frozen_string_literal: true

require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/unit/**/*_test.rb']
  t.warning = false
end

namespace :test do
  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.test_files = FileList['test/integration/**/*_test.rb']
    t.warning = false
  end
end

RBS_OPTIONS = %w[-I sig -r logger -r date].freeze

namespace :rbs do
  desc 'Validate the RBS signatures in sig/'
  task :validate do
    sh 'rbs', *RBS_OPTIONS, 'validate'
  end

  desc 'Run the unit tests with RBS runtime type checking of the signed classes'
  task :test do
    env = {
      'RBS_TEST_TARGET' => 'Zm::*',
      'RBS_TEST_OPT' => RBS_OPTIONS.join(' '),
      'RBS_TEST_LOGLEVEL' => 'error',
      'RUBYOPT' => "#{ENV.fetch('RUBYOPT', nil)} -rrbs/test/setup".strip
    }
    sh env, FileUtils::RUBY, '-S', 'rake', 'test'
  end
end

task default: :test
