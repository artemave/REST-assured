$:.push File.expand_path('../../../lib', __FILE__)
require 'rubygems'
require 'spork'

Spork.prefork do
  require 'timeout'
  require 'rspec'
  require 'rack/test'
  require 'capybara'
  require 'capybara/firebug'
  require 'capybara/cucumber'
  require 'database_cleaner'
  require 'awesome_print'
  require 'rest-assured/utils/port_explorer'
  require File.dirname(__FILE__) + '/world_helpers'

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

  World(Capybara, Rack::Test::Methods, RackHeaderHack, WorldHelpers)

end


Spork.each_run do
  require 'rest-assured/config'
  RestAssured::Config.build(:adapter => 'mysql')
  require 'rest-assured'

  def app
    RestAssured::Application
  end
  Capybara.app = app

  DatabaseCleaner.strategy = :truncation

  Before do
    DatabaseCleaner.start
  end

  Before "@ruby_api" do
    RestAssured::Server.start(:port => 9876, :db_user => ENV['TRAVIS'] ? "''" : "root")
  end

  Before "@ui" do
    set_headers "HTTP_USER_AGENT" => 'Firefox'
  end

  After do
    sleep 0.1
    DatabaseCleaner.clean

    @t.join if @t.is_a?(Thread)
  end
end

