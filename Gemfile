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
    gem 'growl_notify'
    gem 'rb-fsevent'
  end
  gem 'sinatra-activerecord'
end
