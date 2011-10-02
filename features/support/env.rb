$:.push File.expand_path('../../../lib', __FILE__)
require 'rubygems'
require 'spork'

Spork.prefork do
  require 'rspec/expectations'
  require 'rack/test'
  require 'capybara'
  require 'capybara/firebug'
  require 'capybara/cucumber'
  require 'database_cleaner'

  ENV['RACK_ENV'] = 'test'

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

  Capybara.register_driver :selenium do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    profile.enable_firebug

    Capybara::Selenium::Driver.new(app, :browser => :firefox, :profile => profile) 
  end

  World(Capybara, Rack::Test::Methods, RackHeaderHack)
end


Spork.each_run do
  require 'rest-assured'

  def app
    RestAssured::Application
  end
  Capybara.app = app

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
end

