require_relative '../lib/fake_rest_services'
require 'rspec'
require 'shoulda-matchers'
require 'capybara/rspec'

Capybara.app = FakeRestServices::Application

RSpec.configure do |c|
  c.include Capybara::DSL
end
