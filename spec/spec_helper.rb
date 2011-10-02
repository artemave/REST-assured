require 'rubygems'
require 'spork'

Spork.prefork do
  require 'capybara/rspec'
  require 'rack/test'
  require 'database_cleaner'

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
  require File.expand_path('../../lib/rest-assured', __FILE__)
  require 'shoulda-matchers'

  DatabaseCleaner.strategy = :truncation

  Capybara.app = RestAssured::Application

  def app
    RestAssured::Application
  end

end
