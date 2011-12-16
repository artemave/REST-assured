source "http://rubygems.org"

# Specify your gem's dependencies in rest-assured.gemspec
gemspec

gem 'cucumber'
gem 'database_cleaner'
gem 'rspec'
gem 'shoulda-matchers'
gem 'rack-test'
gem 'capybara'
gem 'capybara-firebug'
gem 'rake'
gem 'mysql2'
gem 'sqlite3', '~> 1.3.4'
gem 'thin'
gem 'relish'

group :local do
  gem RUBY_VERSION =~ /^1\.8/ ? 'ruby-debug' : 'ruby-debug19'
  gem 'awesome_print'
  gem 'interactive_editor'
  gem 'launchy'
  gem "spork", "> 0.9.0.rc"
  gem "guard-spork"
  if RUBY_PLATFORM =~ /darwin/
    gem 'growl_notify'
    gem 'rb-fsevent'
  end
  gem 'sinatra-activerecord'
end
