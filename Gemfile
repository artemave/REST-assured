source "http://rubygems.org"

# Specify your gem's dependencies in rest-assured.gemspec
gemspec

gem 'pg'
gem 'thin'

# skipped for heroku
group :test do
  gem 'cucumber'
  gem 'database_cleaner'
  gem 'rspec'
  gem 'shoulda-matchers'
  gem 'rack-test'
  gem 'capybara'
  gem 'rake'
  gem 'mysql2'
  gem 'sqlite3'
  gem 'chromedriver-helper'

  gem 'simplecov', :platforms => :ruby_19
  gem 'awesome_print'
  gem "spork", "> 0.9.0.rc"
end

# skipped for heroku and travis
group :development do
  gem 'relish'
  gem 'interactive_editor'
  gem 'launchy'
  gem "guard-spork"
  gem 'growl'
  gem 'rb-fsevent'
  gem 'rb-readline'
end

