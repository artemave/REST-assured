$:.push File.expand_path('../../../lib', __FILE__)
require 'rspec/expectations'
require 'rack/test'
require 'capybara'
require 'capybara/firebug'
require 'capybara/cucumber'
require 'database_cleaner'
require 'logger'

ENV['RACK_ENV'] = 'test'

require 'fake_rest_services'

module RackHeaderHack
  def set_headers(headers)
    browser = page.driver.browser
    def browser.env
      @env.merge(super)
    end
    def browser.env=(env)
      @env = env
    end
    browser.env = headers
  end
end

def setup_logger
  Logger.class_eval do
     alias_method :write, :<<
  end

  logger = Logger.new(File.expand_path("../../../test.log", __FILE__))
  logger.level = Logger::DEBUG

  FakeRestServices::Application.class_eval do
    use Rack::CommonLogger, logger
  end

  ActiveRecord::Base.logger = logger
end

setup_logger

def app
  FakeRestServices::Application
end
Capybara.app = app

Capybara.register_driver :selenium do |app|
  profile = Selenium::WebDriver::Firefox::Profile.new
  profile.enable_firebug

  Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile) 
end

World(Capybara, Rack::Test::Methods, RackHeaderHack)

DatabaseCleaner.strategy = :truncation

Before do
  DatabaseCleaner.start
end

Before "@ui" do
  set_headers "HTTP_USER_AGENT" => 'Firefox'
end

After do
  DatabaseCleaner.clean
end

