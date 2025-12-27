# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.name          = 'zm-ruby-client'
  s.version       = File.read(File.expand_path('./VERSION', __dir__)).strip
  s.summary       = 'zm-ruby-client'
  s.description   = 'Zimbra Soap Librairy using SOAP Json interface'

  s.required_ruby_version = '>= 3.2'
  s.required_rubygems_version = '>= 1.8.11'

  s.license       = 'GPL-3.0-only'

  s.authors       = ['Maxime Désécot']
  s.email         = 'maxime.desecot@gmail.com'
  s.homepage      = 'https://github.com/RaoH37/zm-ruby-client'

  s.files         = `git ls-files`.split("\n").reject { |path| path.start_with?('test/', 'examples/') }
  s.require_paths = ['lib']

  s.add_dependency 'bundler', '>= 1.15.0'
  s.add_dependency 'faraday', '>= 2.14'
  s.add_dependency 'faraday-multipart', '>= 1.1'
  s.add_dependency 'msgpack', '>= 1.8.0'
  s.metadata['rubygems_mfa_required'] = 'true'
end
