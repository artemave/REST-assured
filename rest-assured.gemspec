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

  s.add_dependency 'sinatra'
  s.add_dependency 'rack-flash'
  #s.add_dependency 'sinatra-reloader'
  s.add_dependency 'haml'
  s.add_dependency 'sass'
  s.add_dependency 'activerecord', '~> 3.0.0'
  s.add_dependency 'sinatra-activerecord'
  s.add_dependency 'sqlite3'
  s.add_dependency 'meta_where'
end

