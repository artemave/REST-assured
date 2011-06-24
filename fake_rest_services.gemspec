# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'fake_rest_services/version'

Gem::Specification.new do |s|
  s.name                  = "fake_rest_services"
  s.version               = FakeRestServices::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Artem Avetisyan', 'Jamal Natour']
  s.email                 = ['artem.avetisyan@bbc.co.uk', 'jamal.natour@bbc.co.uk']
  s.homepage              = "https://github.com/artemave/fake_rest_services"
  s.summary               = %q{Sinatra webapp that allows mocking GET to any path with arbitrary content}
  #s.description          = %q{TODO: Write a gem description}

  s.rubyforge_project     = "fake_rest_services"
  s.required_ruby_version = '>= 1.9.0'

  s.extensions            = ['Rakefile']

  s.files                 = `git ls-files`.split("\n")
  s.test_files            = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables           = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths         = ['lib']

  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rack-test'
  s.add_dependency 'sinatra'
  s.add_dependency 'thin'
  s.add_dependency 'activerecord', '~> 3.0.0'
  s.add_dependency 'sinatra-activerecord'
  s.add_dependency 'sqlite3'
  s.add_dependency 'rake'
end

