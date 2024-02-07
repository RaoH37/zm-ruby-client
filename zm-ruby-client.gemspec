# frozen_string_literal: true
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require './lib/zm-ruby-client'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name          = 'zm-ruby-client'
  s.version       = Zm::Client::gem_version.to_s
  s.date          = `date '+%Y-%m-%d'`
  s.summary       = 'zm-ruby-client'
  s.description   = 'Zimbra Soap Librairy using SOAP Json interface'

  s.required_ruby_version = ">= 2.7"
  s.required_rubygems_version = ">= 1.8.11"

  s.license       = 'GPL-3.0'

  s.authors       = ['Maxime Désécot']
  s.email         = 'maxime.desecot@gmail.com'
  s.homepage      = 'https://github.com/RaoH37/zm-ruby-client'

  s.files         = `git ls-files`.split("\n").reject { |path| path.start_with?('test/', 'examples/') }
  s.require_paths = ['lib']

  s.add_dependency('addressable', ['~> 2.8'])
  s.add_dependency('version_sorter', ['~> 2.3'])

  s.add_runtime_dependency 'faraday', '~> 2.8', '>= 2.8.1'
  s.add_runtime_dependency 'faraday-multipart', '~> 1.0', '>= 1.0.4'
  s.add_runtime_dependency 'bundler', '~> 1.15', '>= 1.15.0'
end