$:.push File.expand_path('../../../lib', __FILE__)
require 'rspec/expectations'
require 'rack/test'
require 'fake_rest_services'

World(Rack::Test::Methods)

def app
  FakeRestServices::Application
end
