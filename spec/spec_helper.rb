ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
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

$:.unshift(File.expand_path('../../lib'), __FILE__)

require 'rspec'
require 'capybara/rspec'
require 'rack/test'
require 'awesome_print'
require 'rest-assured/config'

DB_OPTS = {
  adapter: 'sqlite3',
}
RestAssured::Config.build(DB_OPTS)

require 'rest-assured'
require 'rest-assured/application'

Capybara.app = RestAssured::Application

def app
  RestAssured::Application
end

require 'database_cleaner'
require File.expand_path('../support/custom_matchers', __FILE__)
require File.expand_path('../support/reset-singleton', __FILE__)

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

  c.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  c.around(:each) do |example|
    begin
      DatabaseCleaner.cleaning do
        example.run
      end
    rescue ActiveRecord::StatementInvalid
      ActiveRecord::Base.connection.reconnect!
      DatabaseCleaner.clean_with :truncation
    end
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
