# frozen_string_literal: true
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require './lib/zm-ruby-client'

Gem::Specification.new do |s|
  s.name          = 'zm-ruby-client'
  s.version       = Zm::Client::gem_version.to_s
  s.date          = `date '+%Y-%m-%d'`
  s.summary       = 'zm-ruby-client'
  s.description   = 'Zimbra Soap Librairy using SOAP Json interface'
  s.authors       = ['Maxime Désécot']
  s.email         = 'maxime.desecot@gmail.com'
  s.files         = `git ls-files`.split("\n")
  s.homepage      = 'https://github.com/RaoH37/zm-ruby-client'
  s.require_paths = ['lib']
  s.license       = 'GPL-3.0'

  s.add_dependency('addressable', ['~> 2.8'])
  s.add_dependency('curb', ['~> 1.0'])
  # s.add_dependency('nokogiri', ['~> 1.10.1'])
  # s.add_dependency('gyoku', ['~> 1.3.1'])
  s.add_dependency('version_sorter', ['~> 2.3.0'])
end