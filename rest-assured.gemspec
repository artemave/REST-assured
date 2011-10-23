# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rest-assured/version'

Gem::Specification.new do |s|
  s.name                  = "rest-assured"
  s.version               = RestAssured::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Artem Avetisyan']
  s.email                 = ['artem.avetisyan@bbc.co.uk']
  s.homepage              = "https://github.com/BBC/rest-assured"
  s.summary               = %q{A tool for high level mocking/stubbing HTTP based REST services}
  #s.description          = %q{TODO: Write a gem description}

  s.rubyforge_project     = "rest-assured"
  s.required_ruby_version = '>= 1.8.7'

  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = ['rest-assured']
  s.require_paths         = ['lib']

  s.add_dependency 'sinatra', '>= 1.3.1'
  s.add_dependency 'rack-flash', '>= 0.1.2'
  s.add_dependency 'haml', '>= 3.1.3'
  s.add_dependency 'sass', '>= 3.1.8'
  s.add_dependency 'activerecord', '~> 3.1.0'
  s.add_dependency 'mysql'
  s.add_dependency 'sqlite3', '~> 1.3.4'
  s.add_dependency 'activeresource', '~> 3.1.0'
end

