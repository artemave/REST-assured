source "https://rubygems.org"

gemspec

gem 'pg'

# skipped for heroku
group :test do
  gem 'cucumber'
  gem 'database_cleaner'
  gem 'rspec'
  gem 'shoulda-matchers'
  gem 'anticipate'
  gem 'rack-test'
  gem 'capybara', '~> 1.1'
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
  gem 'pry'
  gem 'pry-doc'
  gem 'pry-stack_explorer', :platforms => :ruby_19
  gem 'pry-debugger', :platforms => :ruby_19
  gem 'launchy'
  gem "guard-spork"
end

