# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'zm-ruby-client'
  s.version     = File.read(File.expand_path('./VERSION', __dir__)).strip
  s.summary     = 'Ruby client for the Zimbra and Carbonio SOAP and REST APIs'
  s.description = 'Ruby library to manage Zimbra and Carbonio through their SOAP (JSON) and REST APIs'

  s.required_ruby_version = '>= 3.3'

  s.license = 'GPL-3.0-only'

  s.authors  = ['Maxime Désécot']
  s.email    = 'maxime.desecot@gmail.com'
  s.homepage = 'https://github.com/RaoH37/zm-ruby-client'

  s.files         = Dir['lib/**/*.{rb,csv,json}'] + %w[VERSION README.md CHANGELOG.md LICENSE]
  s.require_paths = ['lib']

  s.add_dependency 'csv', '~> 3.2'
  s.add_dependency 'faraday', '~> 2.14'
  s.add_dependency 'faraday-multipart', '~> 1.1'
  s.add_dependency 'logger', '~> 1.6'
  s.add_dependency 'msgpack', '~> 1.8'

  s.metadata['source_code_uri'] = s.homepage
  s.metadata['changelog_uri'] = "#{s.homepage}/blob/master/CHANGELOG.md"
  s.metadata['bug_tracker_uri'] = "#{s.homepage}/issues"
  s.metadata['rubygems_mfa_required'] = 'true'
end
