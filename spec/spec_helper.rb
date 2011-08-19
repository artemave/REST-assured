ENV['RACK_ENV'] = 'test'

require 'rubygems'
require 'require_relative' if RUBY_VERSION =~ /^1\.8/
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

module XhrHelpers
  def xhr(path, params = {})
    verb = params.delete(:as) || :get
    send(verb,path, params, "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest")
  end
  alias_method :ajax, :xhr
end

RSpec.configure do |c|
  c.include Capybara::DSL
  c.include Rack::Test::Methods
  c.include XhrHelpers

  c.before(:each) do
    DatabaseCleaner.start
  end

  c.after(:each) do
    DatabaseCleaner.clean
  end

  c.before(:each, :ui => true) do
    header 'User-Agent', 'Firefox'
  end

  c.before(:each, :ui => false) do
    header 'User-Agent', nil
  end
end
