$:.push File.expand_path('../../../lib', __FILE__)

require 'timeout'
require 'rspec'
require 'rack/test'
require 'capybara'
require 'capybara/cucumber'
require 'capybara/poltergeist'
require 'database_cleaner'
require 'anticipate'
require 'awesome_print'
require 'rest-assured/utils/port_explorer'
require 'phantomjs'
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

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)

  # Capybara::Poltergeist::Driver.new(app, :phantomjs => Phantomjs.path)
end
Capybara.javascript_driver = ENV['FF'] ? :selenium : :poltergeist

World(Capybara, Rack::Test::Methods, RackHeaderHack, WorldHelpers, Anticipate)

require 'rest-assured/config'
db_opts = {
  adapter: 'sqlite3'
}
RestAssured::Config.build(db_opts)

require 'rest-assured'

RestAssured::Server.start(db_opts.merge(:port => 19876))

Before "@api_server" do
  RestAssured::Server.stop
end
After "@api_server" do
  RestAssured::Server.start(db_opts.merge(:port => 19876))
end

require 'rest-assured/application'

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
  sleep 0.1
  DatabaseCleaner.clean

  @t.join if @t.is_a?(Thread)
end
