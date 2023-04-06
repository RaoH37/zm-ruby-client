# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require './lib/zm-ruby-client'

Gem::Specification.new do |s|
  s.platform      = Gem::Platform::RUBY
  s.name          = 'zm-ruby-client'
  s.version       = Zm::Client.gem_version.to_s
  s.date          = `date '+%Y-%m-%d'`
  s.summary       = 'zm-ruby-client'
  s.description   = 'Zimbra Soap Librairy using SOAP Json interface'

  s.required_ruby_version = '>= 2.6'
  s.license       = 'GPL-3.0'

  s.authors       = ['Maxime Désécot']
  s.email         = 'maxime.desecot@gmail.com'
  s.homepage      = 'https://github.com/RaoH37/zm-ruby-client'

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency('addressable', ['~> 2.8'])
  s.add_dependency('curb', ['~> 1.0'])
  s.add_dependency('version_sorter', ['~> 2.3.0'])
end
