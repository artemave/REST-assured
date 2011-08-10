require_relative '../lib/fake_rest_services'
require 'rspec'
require 'shoulda-matchers'
require 'capybara/rspec'
require 'rack/test'
require 'database_cleaner'

Capybara.app = FakeRestServices::Application

def app
  FakeRestServices::Application
end

DatabaseCleaner.strategy = :truncation

RSpec.configure do |c|
  c.include Capybara::DSL
  c.include Rack::Test::Methods

  c.before(:each) do
    DatabaseCleaner.start
  end

  c.after(:each) do
    DatabaseCleaner.clean
  end

  c.before(:each, ui: true) do
    header 'User-Agent', 'Firefox'
  end

  c.before(:each, ui: false) do
    header 'User-Agent', nil
  end
end
