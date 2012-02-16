source "http://rubygems.org"

# Specify your gem's dependencies in rest-assured.gemspec
gemspec

gem 'awesome_print'
gem 'cucumber'
gem 'database_cleaner'
gem 'rspec'
gem 'shoulda-matchers'
gem 'rack-test'
gem 'capybara'
gem 'capybara-firebug'
gem 'rake'
gem 'mysql2'
gem 'sqlite3'
gem 'thin'
gem 'relish'
gem "spork", "> 0.9.0.rc"
gem 'childprocess'

group :local do
  gem 'ruby-debug', :platform => :mri_18
  gem 'ruby-debug19', :platform => :mri_19
  gem 'awesome_print'
  gem 'interactive_editor'
  gem 'launchy'
  gem "guard-spork"
  if RUBY_PLATFORM =~ /darwin/
    gem 'growl'
    gem 'rb-fsevent'
    gem 'rb-readline'
  end
  gem 'sinatra-activerecord'
  gem 'simplecov', :require => false, :platforms => :ruby_19
end

