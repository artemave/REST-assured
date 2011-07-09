$:.push File.expand_path('../../../lib', __FILE__)
require 'rspec/expectations'
require 'rack/test'
require 'capybara'
require 'capybara/cucumber'
require 'database_cleaner'
require 'fake_rest_services'

def app
  FakeRestServices::Application
end
Capybara.app = app

World(Capybara, Rack::Test::Methods)

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end

