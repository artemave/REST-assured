require 'rubygems'
require 'spork'

$:.unshift(File.expand_path('../../lib'), __FILE__)

Spork.prefork do
  require 'capybara/rspec'
  require 'rack/test'
  require 'database_cleaner'
  require File.expand_path('../custom_matchers', __FILE__)

  ENV['RACK_ENV'] = 'test'

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
end

Spork.each_run do
  require 'rest-assured/config'
  RestAssured::Config.build(:adapter => 'mysql')

  require 'rest-assured'
  require 'rest-assured/client'
  require 'shoulda-matchers'
  require File.expand_path('../../features/support/test-server', __FILE__)

  at_exit do
    TestServer.stop
  end

  TestServer.start(:port => 9876, :db_user => ENV['TRAVIS'] ? "''" : "root")

  while not TestServer.up?
    puts 'Waiting for TestServer to come up...'
    sleep 1
  end

  RestAssured::Client.config.server_address = 'http://localhost:9876'

  Capybara.app = RestAssured::Application

  def app
    RestAssured::Application
  end

  DatabaseCleaner.strategy = :truncation
end
