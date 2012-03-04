source "http://rubygems.org"

# Specify your gem's dependencies in rest-assured.gemspec
gemspec

gem 'pg'
gem 'thin'

# skipped for heroku
group :test do
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
  gem 'relish'
  gem 'sinatra-activerecord'
  gem "spork", "> 0.9.0.rc"
  gem 'simplecov', :platforms => :ruby_19
end

# skipped for heroku and travis
group :development do
  gem 'ruby-debug', :platform => :mri_18
  gem 'ruby-debug19', :platform => :mri_19
  gem 'interactive_editor'
  gem 'launchy'
  gem "guard-spork"
  gem 'growl'
  gem 'rb-fsevent'
  gem 'rb-readline'
end

