# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'rest-assured/version'

Gem::Specification.new do |s|
  s.name                  = "rest-assured"
  s.version               = RestAssured::VERSION
  s.platform              = Gem::Platform::RUBY
  s.authors               = ['Artem Avetisyan']
  s.email                 = ['artemave@gmail.com']
  s.homepage              = "https://github.com/artemave/rest-assured"
  s.summary               = %q{Real stubs and spies for HTTP(S) services}
  #s.description          = %q{TODO: Write a gem description}

  s.rubyforge_project     = "rest-assured"
  s.required_ruby_version = '>= 2.2.2'

  s.files                 = Dir['CHANGELOG', 'README.markdown', 'LICENSE', '{lib,db,public,views,ssl}/**/*']
  s.test_files            = Dir['{spec,features}/**/*']
  s.executables           = ['rest-assured']
  s.require_paths         = ['lib']

  s.add_dependency 'sinatra', ['>= 1.4.0', '~> 2.0']
  s.add_dependency 'childprocess', '~> 0.3'
  s.add_dependency 'sinatra-flash'
  s.add_dependency 'haml', ['>= 4.0', '~> 5.0']
  s.add_dependency 'activerecord', ['>= 4.0', '~> 5.0']
  s.add_dependency 'activeresource', ['>= 4.0', '~> 5.0']
  s.add_dependency 'thin', '~> 1.6'
end

