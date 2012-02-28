require 'rubygems'

if RUBY_VERSION =~ /^1.9/
  begin
    require 'simplecov'
    SimpleCov.start do
      at_exit {} # reset built in at_exit or else it gets triggered when RestAssured::Server.stop is called from tests
      add_filter "/spec/"
      add_filter "/sinatra/"
    end
  rescue LoadError
  end
end

require 'spork'

$:.unshift(File.expand_path('../../lib'), __FILE__)

Spork.prefork do
  require 'rspec'
  require 'capybara/rspec'
  require 'rack/test'
  require 'database_cleaner'
  require 'awesome_print'
  require File.expand_path('../support/custom_matchers', __FILE__)
  require File.expand_path('../support/reset-singleton', __FILE__)

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

    if defined?(SimpleCov)
      c.after(:suite) do
        SimpleCov.result.format!
      end
    end
  end
  require 'rest-assured/config'
  db_opts = { :dbuser => ENV['TRAVIS'] ? "''" : "root", :adapter => 'mysql' }
  RestAssured::Config.build(db_opts)

  require 'rest-assured'
  require 'rest-assured/application'
  require 'shoulda-matchers'

  RestAssured::Server.start(db_opts.merge(:port => 9877))

  Capybara.app = RestAssured::Application

  def app
    RestAssured::Application
  end

  DatabaseCleaner.strategy = :truncation
end

Spork.each_run do
end
